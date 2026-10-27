import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { assertCompatible, injectVideos, MediaStore, parseCommand } from "./media";
import { transformVideoInput } from "./input";

export default function videoExtension(pi: ExtensionAPI) {
  const agentDir = process.env.PI_CODING_AGENT_DIR || join(homedir(), ".omp", "agent");
  async function store() {
    let config = {};
    try { config = JSON.parse(await readFile(join(agentDir, "video.json"), "utf8")); }
    catch (error: any) { if (error.code !== "ENOENT") throw error; }
    return new MediaStore(join(agentDir, "video-attachments"), config);
  }
  const report = (ctx: any, error: unknown) => {
    const message = `Video: ${error instanceof Error ? error.message : String(error)}`;
    if (ctx.hasUI) ctx.ui.notify(message, "error");
    else console.error(message);
  };
  pi.on("input", async (event, ctx) => {
    if (!event.images?.length && !/\[Video #\d+/.test(event.text)) return;
    try { return await transformVideoInput(event, ctx.model, await store(), ctx.cwd); }
    catch (error) {
      report(ctx, error);
      // Returning handled prevents hook errors from falling through to the
      // command parser or sending just the preview as though it were a video.
      return { handled: true };
    }
  });
  pi.registerCommand("video", {
    description: 'Attach video/GIF: /video "path or URL" -- question',
    handler: async (args, ctx) => {
      try {
        const oneShot = ctx.mode === "print" || ctx.mode === "json";
        if (!oneShot && !ctx.isIdle()) throw new Error("Wait for the current turn to finish before attaching a video");
        const media = await store();
        if (!args.trim() || args.trim() === "help") {
          const help = `/video "path/to/clip.mp4" -- question\nLimits: ${media.limits.maxBytes / 1024 / 1024} MiB/file, ${media.limits.maxSeconds}s, ${media.limits.maxVideos} videos/request (including history). Config: ${join(agentDir, "video.json")}`;
          if (ctx.hasUI) ctx.ui.notify(help, "info");
          // Keep the one-shot stdout stream clean: help and errors go to stderr.
          else console.error(help);
          return;
        }
        assertCompatible(ctx.model, media.limits);
        const { source, prompt } = parseCommand(args);
        const attachment = await media.attach(source, ctx.cwd);
        const text = `${prompt}\n\n${attachment.text}`;
        if (!oneShot) {
          pi.sendUserMessage(attachment.image ? [{ type: "text", text }, attachment.image] : text);
          return;
        }
        // One-shot modes exit right after command dispatch, so a queued
        // sendUserMessage turn never runs. runEphemeralTurn answers inside this
        // handler instead; its side-request still fires
        // before_provider_request, so [omp-video:...] injection and cache
        // integrity checks apply unchanged.
        // shortcut: the reply is not persisted to the session transcript;
        // upgrade if print sessions need resumable video turns.
        const frame = (value: object) => process.stdout.write(JSON.stringify(value) + "\n");
        const timestamp = Date.now();
        const userMessage = { role: "user", content: [{ type: "text", text }], attribution: "user", timestamp };
        const history = attachment.image
          ? [{ role: "user", content: [attachment.image], attribution: "user", timestamp }]
          : undefined;
        if (ctx.mode === "json") {
          frame({ type: "agent_start" });
          frame({ type: "turn_start" });
          frame({ type: "message_start", message: userMessage });
          frame({ type: "message_end", message: userMessage });
        }
        let streamed = false;
        const result = await ctx.runEphemeralTurn({
          promptText: text,
          history,
          onTextDelta: async (delta: string) => {
            streamed = true;
            if (ctx.mode === "json") frame({ type: "message_update", assistantMessageEvent: { type: "text_delta", contentIndex: 0, delta } });
            else process.stdout.write(delta);
          },
        });
        if (ctx.mode === "json") {
          frame({ type: "message_start", message: { ...result.assistantMessage, content: [{ type: "text", text: result.replyText }] } });
          frame({ type: "message_end", message: result.assistantMessage });
          frame({ type: "turn_end", message: result.assistantMessage, toolResults: [] });
          frame({ type: "agent_end", messages: [userMessage, result.assistantMessage] });
        } else {
          if (!streamed && result.replyText) process.stdout.write(result.replyText);
          process.stdout.write("\n");
        }
      } catch (error) { report(ctx, error); }
    },
  });

  // Guard before serialization too: other APIs don't use a `messages` payload.
  pi.on("context", async (event, ctx) => {
    const hasVideo = event.messages.some(m => m.role === "user" && /\[omp-video:[a-f0-9]{64}\]/.test(JSON.stringify(m.content)));
    if (!hasVideo) return;
    try { assertCompatible(ctx.model, (await store()).limits); }
    catch (error) { ctx.abort(); report(ctx, error); }
  });
  pi.on("before_provider_request", async (event, ctx) => {
    // No filesystem work on ordinary requests.
    if (!JSON.stringify(event.payload).includes("[omp-video:")) return;
    try { return await injectVideos(event.payload, ctx.model, await store()); }
    catch (error) {
      // omp reports hook exceptions and continues; explicitly abort to prevent
      // silently sending a text-only request when media cannot be delivered.
      ctx.abort();
      report(ctx, error);
      throw error;
    }
  });
}
