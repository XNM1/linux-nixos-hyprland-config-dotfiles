import { expect, test } from "bun:test";
import { transformVideoInput } from "../input";

const model = { provider: "vllm", api: "openai-completions", id: "qwen3.8-flash-next" };
const id = "a".repeat(64);
const preview = (path = "/tmp/clip.mp4", kind = "video") => ({
  type: "image" as const, mimeType: "image/png", data: "preview",
  [Symbol("image.attachmentSource")]: { path, kind },
});
function store() {
  const calls: string[] = [];
  return {
    calls,
    limits: { models: ["vllm/qwen3.8-flash-next"], maxVideos: 2 },
    async attach(path: string) {
      calls.push(path);
      return { id, text: `[Video: clip.mp4 · 1.00s]\n[omp-video:${id}]` };
    },
  };
}

test("screenshot regression: /video with a dimensioned native chip resolves the original file", async () => {
  const media = store();
  const original = preview();
  const result = await transformVideoInput({ text: "/video [Video #1, 1143x200] --What happened in this video?", images: [original] }, model, media as any, "/tmp");
  expect(media.calls).toEqual(["/tmp/clip.mp4"]);
  expect(result?.text).toContain("What happened in this video?");
  expect(result?.text).not.toContain("/video");
  expect(result?.text).not.toContain("[Video #1");
  expect(result?.text).toContain(`[omp-video:${id}]`);
  expect(result?.images).toEqual([]);
  expect(original.data).toBe("preview");
});

test("ordinary pasted video works without /video and preserves other images with renumbered markers", async () => {
  const image = { type: "image" as const, mimeType: "image/png", data: "other" };
  const result = await transformVideoInput({ text: "Compare [Video #1, 64x64] with [Image #2, 32x32]", images: [preview(), image] }, model, store() as any, "/tmp");
  expect(result?.images).toEqual([image]);
  expect(result?.text).toContain("[Image #1, 32x32]");
  expect(result?.text).toContain("Compare");
});

test("raw URLs, unrelated commands, and ordinary images are left alone", async () => {
  for (const input of [
    { text: '/video "https://example.com/clip.mp4" -- explain', images: [] },
    { text: "/help [Video #1]", images: [preview()] },
    { text: "Describe [Image #1]", images: [{ type: "image", mimeType: "image/png", data: "image" }] },
  ]) expect(await transformVideoInput(input as any, model, store() as any, "/tmp")).toBeUndefined();
});

test("video-only input gets a default question and no stale preview", async () => {
  const result = await transformVideoInput({ text: "/video [Video #1]", images: [preview()] }, model, store() as any, "/tmp");
  expect(result?.text).toContain("Describe what happens in this video.");
  expect(result?.images).toEqual([]);
});

test("missing original metadata is an actionable error, never a guessed clipboard attachment", async () => {
  await expect(transformVideoInput({ text: "/video [Video #1] -- Explain", images: [{ type: "image", mimeType: "image/png", data: "preview" }] }, model, store() as any, "/tmp")).rejects.toThrow("original video path");
});

test("compatibility and attachment-count checks run before reading files", async () => {
  const media = store();
  await expect(transformVideoInput({ text: "[Video #1]", images: [preview()] }, { ...model, provider: "other" }, media as any, "/tmp")).rejects.toThrow("not enabled");
  await expect(transformVideoInput({ text: "[Video #1] [Video #2] [Video #3]", images: [preview(), preview(), preview()] }, model, media as any, "/tmp")).rejects.toThrow("count limit");
  expect(media.calls).toEqual([]);
});

test("file-backed GIF chips use original animation instead of normalized PNG", async () => {
  const media = store();
  await transformVideoInput({ text: "Explain [Image #1]", images: [preview("/tmp/animation.gif", "image")] }, model, media as any, "/tmp");
  expect(media.calls).toEqual(["/tmp/animation.gif"]);
});
