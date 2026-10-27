import { expect, test } from "bun:test";
import { mkdtemp, mkdir, writeFile, symlink, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

// One-shot modes must answer the video prompt inside the command: omp exits
// after command dispatch, so the ephemeral turn is the only turn that can run.
test("print and json one-shot modes send video_url and print the reply", async () => {
  const dir = await mkdtemp(join(tmpdir(), "omp-video-print-"));
  const requests: any[] = [];
  const server = Bun.serve({ port: 0, hostname: "127.0.0.1", async fetch(req) {
    if (new URL(req.url).pathname !== "/v1/chat/completions") return Response.json({ data: [] });
    const body = await req.json();
    requests.push(body);
    const chunk = (delta: any, finish_reason: string | null = null) => `data: ${JSON.stringify({ id: "test", object: "chat.completion.chunk", created: 0, model: body.model, choices: [{ index: 0, delta, finish_reason }] })}\n\n`;
    return new Response(chunk({ role: "assistant", content: "A red video." }) + chunk({}, "stop") + "data: [DONE]\n\n", { headers: { "content-type": "text/event-stream" } });
  } });
  try {
    const agent = join(dir, "agent");
    await mkdir(join(agent, "extensions"), { recursive: true });
    await symlink(resolve(import.meta.dir, ".."), join(agent, "extensions", "video"));
    await writeFile(join(agent, "models.yml"), `providers:\n  vllm:\n    baseUrl: http://127.0.0.1:${server.port}/v1\n    api: openai-completions\n    apiKey: test\n    models:\n      - id: qwen3.8-flash-next\n        name: Test video\n        input: [text, image]\n        contextWindow: 32768\n        maxTokens: 128\n`);
    const clip = join(dir, "clip.mp4");
    const ff = Bun.spawn(["ffmpeg", "-v", "error", "-f", "lavfi", "-i", "color=c=red:s=64x64:d=1", "-c:v", "libx264", clip], { stdout: "pipe", stderr: "pipe" });
    expect(await ff.exited).toBe(0);
    const run = async (args: string[]) => {
      const p = Bun.spawn(["omp", "--no-skills", "--no-rules", "--no-tools", "--no-title", "--model", "vllm/qwen3.8-flash-next", "--thinking", "off", ...args], { cwd: dir, env: { ...process.env, PI_CODING_AGENT_DIR: agent }, stdin: "ignore", stdout: "pipe", stderr: "pipe" });
      const timer = setTimeout(() => p.kill(), 30000);
      try {
        const [out, err] = await Promise.all([new Response(p.stdout).text(), new Response(p.stderr).text()]);
        return { out, err, code: await p.exited };
      } finally { clearTimeout(timer); p.kill(); }
    };
    const videos = (body: any) => body.messages.flatMap((m: any) => Array.isArray(m.content) ? m.content.filter((c: any) => c.type === "video_url") : []);
    const print = await run(["-p", `/video "${clip}" -- What color?`]);
    expect(requests.length, JSON.stringify(print)).toBe(1);
    expect(videos(requests[0]).length).toBe(1);
    expect(print.out).toContain("A red video.");
    requests.length = 0;
    const json = await run(["--mode", "json", "-p", `/video "${clip}" -- What color?`]);
    expect(videos(requests.at(-1)).length, JSON.stringify(json)).toBe(1);
    const frames = json.out.split("\n").filter(Boolean).map(line => JSON.parse(line));
    const end = frames.find(f => f.type === "agent_end");
    expect(JSON.stringify(end?.messages)).toContain("A red video.");
    expect(frames.some(f => f.type === "message_update" && f.assistantMessageEvent?.delta)).toBe(true);
  } finally { server.stop(true); await rm(dir, { recursive: true, force: true }); }
}, 100000);
