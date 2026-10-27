import { afterAll, beforeAll, expect, test } from "bun:test";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MediaStore, injectVideos, parseCommand } from "../media";

let dir: string;
let clip: string;
beforeAll(async () => {
  dir = await mkdtemp(join(tmpdir(), "omp-video-test-"));
  clip = join(dir, "a clip.mp4");
  const p = Bun.spawn(["ffmpeg", "-v", "error", "-f", "lavfi", "-i", "color=c=red:s=64x64:d=1", "-c:v", "libx264", "-y", clip], { stdout: "pipe", stderr: "pipe" });
  expect(await p.exited).toBe(0);
});
afterAll(async () => { await rm(dir, { recursive: true, force: true }); });

const model = { provider: "vllm", api: "openai-completions", id: "qwen3.8-flash-next" };
test("quoted dropped paths and questions are parsed without shell execution", () => {
  expect(parseCommand('"/tmp/a clip.mp4" -- What moves?')).toEqual({ source: "/tmp/a clip.mp4", prompt: "What moves?" });
  expect(parseCommand("/tmp/a\\ clip.mp4").source).toBe("/tmp/a clip.mp4");
});

test("local video persists independently of the source and replays as video_url", async () => {
  const cache = join(dir, "cache");
  const store = new MediaStore(cache);
  const attachment = await store.attach(clip, dir);
  const payload = { messages: [{ role: "user", content: attachment.text }] };
  const output = await injectVideos(payload, model, new MediaStore(cache));
  expect(output.messages[0].content[1].type).toBe("video_url");
  expect(output.messages[0].content[1].video_url.url).toStartWith("data:video/mp4;base64,");
  expect(payload.messages[0].content).toBe(attachment.text);
  expect(attachment.text).toContain("1.00s");
});

test("rejects oversized, long, non-video files and unsupported models", async () => {
  await expect(new MediaStore(join(dir, "small"), { maxBytes: 1 }).attach(clip, dir)).rejects.toThrow("size limit");
  await expect(new MediaStore(join(dir, "short"), { maxSeconds: 0.1 }).attach(clip, dir)).rejects.toThrow("duration limit");
  const invalid = join(dir, "fake.mp4");
  await writeFile(invalid, "not video");
  await expect(new MediaStore(join(dir, "invalid")).attach(invalid, dir)).rejects.toThrow();
  const store = new MediaStore(join(dir, "compat"));
  const a = await store.attach(clip, dir);
  await expect(injectVideos({ messages: [{ role: "user", content: a.text }] }, { ...model, provider: "openai" }, store)).rejects.toThrow("not enabled");
});

test("enforces cumulative request limits and does not inject assistant quotations", async () => {
  const store = new MediaStore(join(dir, "count"), { maxVideos: 1 });
  const a = await store.attach(clip, dir);
  await expect(injectVideos({ messages: [{ role: "user", content: a.text }, { role: "user", content: a.text }] }, model, store)).rejects.toThrow("video count");
  const payload = { messages: [{ role: "assistant", content: a.text }] };
  expect(await injectVideos(payload, model, store)).toEqual(payload);
});

test("missing or modified cache fails clearly instead of dropping the video", async () => {
  const store = new MediaStore(join(dir, "missing"));
  const a = await store.attach(clip, dir);
  await rm(join(store.root, `${a.id}.media`));
  await expect(injectVideos({ messages: [{ role: "user", content: a.text }] }, model, store)).rejects.toThrow("missing");
});

test("explicit remote URL is snapshotted and bounded, including chunked responses", async () => {
  const bytes = await Bun.file(clip).arrayBuffer();
  const server = Bun.serve({ port: 0, hostname: "127.0.0.1", fetch(req) {
    if (new URL(req.url).pathname === "/redirect") return Response.redirect(`http://127.0.0.1:${server.port}/clip.mp4`);
    return new Response(new ReadableStream({ start(c) { c.enqueue(new Uint8Array(bytes)); c.close(); } }));
  } });
  try {
    const store = new MediaStore(join(dir, "remote"));
    const a = await store.attach(`http://127.0.0.1:${server.port}/redirect`, dir);
    expect((await store.load(a.id)).url).toStartWith("data:video/mp4;base64,");
    await expect(new MediaStore(join(dir, "remote-small"), { maxBytes: 10 }).attach(`http://127.0.0.1:${server.port}/clip.mp4`, dir)).rejects.toThrow("size limit");
  } finally { server.stop(true); }
});

test("animated GIF preserves motion as video; static GIF remains an image", async () => {
  const gif = join(dir, "animated.gif");
  const staticGif = join(dir, "static.gif");
  for (const [path, args] of [[gif, ["-t", "1"]], [staticGif, ["-frames:v", "1"]]] as const) {
    const p = Bun.spawn(["ffmpeg", "-v", "error", "-f", "lavfi", "-i", "testsrc=size=64x64:rate=10", ...args, path], { stdout: "pipe", stderr: "pipe" });
    expect(await p.exited).toBe(0);
  }
  const store = new MediaStore(join(dir, "gif"));
  const a = await store.attach(gif, dir);
  expect(a.text).toContain("animated.gif");
  expect((await store.load(a.id)).url).toStartWith("data:video/mp4;base64,");
  const decoded = Bun.spawn(["ffmpeg", "-v", "error", "-i", join(store.root, `${a.id}.media`), "-f", "framemd5", "-"], { stdout: "pipe", stderr: "pipe" });
  const frameHashes = (await new Response(decoded.stdout).text()).split("\n").filter(l => l && !l.startsWith("#")).map(l => l.split(",").at(-1)?.trim());
  expect(await decoded.exited).toBe(0);
  expect(new Set(frameHashes).size).toBeGreaterThan(1);
  expect(a.text).toContain("1.00s");
  const still = await store.attach(staticGif, dir);
  expect(still.image?.mimeType).toBe("image/gif");
  expect(still.text).not.toContain("[omp-video:");
});
