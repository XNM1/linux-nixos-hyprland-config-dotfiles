// Shrink large successful bash outputs through caveman-engine before they enter model context.
// Measured: ~10-13% on realistic build logs, up to ~99% on repeated identical lines; anything else passes through.
import { execFile } from "node:child_process";

const ENGINE = "/home/xnm/.caveman/bin/caveman-engine";
const TIMEOUT_MS = 3000;
const MIN_CHARS = 3000; // below: pass through, savings not worth a rewrite
const MIN_KEEP = 0.90;  // replace only when compressed bytes drop >10% (engine returns input verbatim when it declines)

interface TextChunk { type: string; text?: string }
interface ToolResultEvent { toolName: string; isError: boolean; content: TextChunk[] }
interface PiApi { on(event: string, handler: (ev: unknown) => Promise<unknown>): void }

export default function (pi: PiApi): void {
  pi.on("tool_result", async (raw: unknown) => {
    const ev = raw as ToolResultEvent;
    if (ev.toolName !== "bash" || ev.isError) return; // errors stay verbatim: never hide the decisive line
    if (!ev.content.every((c) => c.type === "text")) return; // keep images/attachments intact
    const text = ev.content.map((c) => c.text ?? "").join("\n");
    if (text.length < MIN_CHARS) return;

    // Invoke the engine directly so the deadline kills the worker, not a CLI parent.
    const r = await new Promise<{ stdout: string; stderr: string } | undefined>((resolve) => {
      const child = execFile(ENGINE, ["compress"], {
        encoding: "utf8", timeout: TIMEOUT_MS, killSignal: "SIGKILL",
        maxBuffer: 64 * 1024 * 1024,
      }, (error, stdout, stderr) => resolve(error ? undefined : { stdout, stderr }));
      child.stdin?.on("error", () => {}); // Early exit can close stdin before input is written.
      child.stdin?.end(text);
    });
    if (!r?.stdout) return; // engine missing/crash/timeout -> preserve the original result
    if (r.stdout.length >= text.length * MIN_KEEP) return;

    let metrics: { tokens_before?: number; tokens_after?: number; recovery_handle?: string } = {};
    try {
      const parsed: unknown = JSON.parse(r.stderr.trim().split("\n").pop() || "{}");
      if (parsed && typeof parsed === "object") metrics = parsed as typeof metrics;
    } catch { /* metrics are advisory */ }

    const tok = metrics.tokens_before && metrics.tokens_after
      ? `${metrics.tokens_before}->${metrics.tokens_after} tok` : "shrunk";
    const rec = metrics.recovery_handle
      ? `, exact original: caveman retrieve ${metrics.recovery_handle}` : "";
    return {
      content: [{ type: "text", text: `${r.stdout}\n[caveman bash-shrink: ${tok}${rec}]` }],
    };
  });
}
