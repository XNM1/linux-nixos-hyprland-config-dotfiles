import { expect, test } from "bun:test";
import { mkdtemp, mkdir, writeFile, appendFile, rm, symlink } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

test("installed omp sends video_url and replays it on resume", async () => {
  const dir = await mkdtemp(join(tmpdir(), "omp-video-integration-"));
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
    await mkdir(agent);
    await mkdir(join(agent, "extensions"));
    await symlink(resolve(import.meta.dir, ".."), join(agent, "extensions", "video"));
    await writeFile(join(agent, "models.yml"), `providers:\n  vllm:\n    baseUrl: http://127.0.0.1:${server.port}/v1\n    api: openai-completions\n    apiKey: test\n    models:\n      - id: qwen3.8-flash-next\n        name: Test video\n        input: [text, image]\n        contextWindow: 32768\n        maxTokens: 128\n`);
    const clip = join(dir, "clip.mp4");
    const ff = Bun.spawn(["ffmpeg", "-v", "error", "-f", "lavfi", "-i", "color=c=red:s=64x64:d=1", "-c:v", "libx264", clip], { stdout: "pipe", stderr: "pipe" });
    expect(await ff.exited).toBe(0);
    const run = async (args: string[], model = "vllm/qwen3.8-flash-next") => {
      const prompt = args.pop()!;
      const p = Bun.spawn(["omp", "--no-skills", "--no-rules", "--no-tools", "--no-title", "--model", model, "--thinking", "off", "--mode", "rpc", ...args], { cwd: dir, env: { ...process.env, PI_CODING_AGENT_DIR: agent }, stdin: "pipe", stdout: "pipe", stderr: "pipe" });
      const timer = setTimeout(() => p.kill(), 30000);
      try {
        p.stdin.write(JSON.stringify({ id: "test-prompt", type: "prompt", message: prompt }) + "\n");
        p.stdin.flush();
        let out = "";
        const errPromise = new Response(p.stderr).text();
        for await (const chunk of p.stdout) {
          out += new TextDecoder().decode(chunk);
          if (out.split("\n").some(line => { try { return JSON.parse(line).type === "agent_end"; } catch { return false; } })) break;
        }
        p.kill();
        const err = await errPromise;
        await p.exited;
        return { out, err };
      } finally { clearTimeout(timer); p.kill(); }
    };
    const result = await run([`/video "${clip}" -- What color?`]);
    expect(requests.length, JSON.stringify(result)).toBeGreaterThan(0);
    const videos = (body: any) => body.messages.flatMap((m: any) => Array.isArray(m.content) ? m.content.filter((c: any) => c.type === "video_url") : []);
    expect(videos(requests.at(-1)).length).toBe(1);
    await rm(clip);
    await run(["--continue", "Describe it again."]);
    expect(videos(requests.at(-1)).length).toBe(1);
    await appendFile(join(agent, "models.yml"), "      - id: text-only\n        name: Text only\n        input: [text]\n        contextWindow: 32768\n        maxTokens: 128\n");
    const beforeSwitch = requests.length;
    const rejected = await run(["--continue", "Describe it with the other model."], "vllm/text-only");
    expect(requests.length).toBe(beforeSwitch);
    expect(rejected.out + rejected.err).toContain("not enabled");
    // A missing cache must abort the request, not send a marker as plain text.
    await rm(join(agent, "video-attachments"), { recursive: true });
    const before = requests.length;
    await run(["--continue", "Describe it once more."]).catch(() => {});
    expect(requests.length).toBe(before);
  } finally { server.stop(true); await rm(dir, { recursive: true, force: true }); }
}, 100000);
