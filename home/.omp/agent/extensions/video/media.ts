import { createHash } from "node:crypto";
import { execFile } from "node:child_process";
import { mkdir, mkdtemp, open, readFile, rename, rm, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, join, resolve } from "node:path";
import { promisify } from "node:util";

const exec = promisify(execFile);
const marker = /^\[omp-video:([a-f0-9]{64})\]$/gm;
export interface Limits {
  maxBytes: number;
  maxSeconds: number;
  maxVideos: number;
  maxRequestBytes: number;
  models: string[];
}
export const defaults: Limits = {
  maxBytes: 20 * 1024 * 1024,
  maxSeconds: 60,
  maxVideos: 2,
  maxRequestBytes: 40 * 1024 * 1024,
  models: ["vllm/qwen3.8-flash-next"],
};
interface Metadata { mime: string; bytes: number; seconds: number; name: string }
interface Attachment { id: string; text: string; image?: { type: "image"; mimeType: string; data: string } }
type Model = { provider: string; api: string; id: string } | undefined;

export function assertCompatible(model: Model, limits: Limits) {
  if (!model || model.api !== "openai-completions" || !limits.models.includes(`${model.provider}/${model.id}`)) {
    throw new Error("Video is not enabled for this model. Select vllm/qwen3.8-flash-next or explicitly enable a verified video model in video.json.");
  }
}

export function parseCommand(args: string): { source: string; prompt: string } {
  const match = args.trim().match(/^(?:"((?:\\.|[^"\\])*)"|'([^']*)'|((?:\\.|[^\s])+))(?:\s+--\s*([\s\S]*))?\s*$/);
  if (!match) throw new Error('Usage: /video "path/to/clip.mp4" -- What happens in this video?');
  const source = match[2] ?? (match[1] ?? match[3]).replace(/\\(.)/g, "$1");
  return { source, prompt: match[4]?.trim() || "Describe what happens in this video." };
}

async function readBounded(path: string, maxBytes: number): Promise<Buffer> {
  const file = await open(path, "r");
  try {
    const info = await file.stat();
    if (!info.isFile()) throw new Error("Video must be a regular file");
    if (info.size > maxBytes) throw new Error("Video exceeds the file size limit");
    const bytes = Buffer.alloc(info.size + 1);
    let offset = 0;
    while (offset < bytes.length) {
      const n = await file.read(bytes, offset, bytes.length - offset, null);
      if (!n.bytesRead) break;
      offset += n.bytesRead;
    }
    if (offset > info.size) throw new Error("Video changed or exceeds the file size limit; retry attachment");
    return bytes.subarray(0, offset);
  } finally { await file.close(); }
}

async function download(source: string, maxBytes: number): Promise<Buffer> {
  const url = new URL(source);
  if (!["http:", "https:"].includes(url.protocol)) throw new Error("Only HTTP(S) attachment URLs are supported");
  if (url.username || url.password) throw new Error("Use a URL without embedded credentials");
  const response = await fetch(url, { signal: AbortSignal.timeout(20_000) });
  if (!response.ok) { await response.body?.cancel(); throw new Error(`Video download failed: HTTP ${response.status}`); }
  if (Number(response.headers.get("content-length")) > maxBytes) {
    await response.body?.cancel();
    throw new Error("Remote video exceeds the file size limit");
  }
  if (!response.body) throw new Error("Remote video is empty");
  const reader = response.body.getReader();
  let total = 0;
  const chunks: Buffer[] = [];
  try {
    while (true) {
      const { value, done } = await reader.read();
      if (done) break;
      total += value.length;
      if (total > maxBytes) throw new Error("Remote video exceeds the file size limit");
      chunks.push(Buffer.from(value));
    }
  } finally { await reader.cancel(); }
  return Buffer.concat(chunks, total);
}

async function probeVideo(path: string, gif = false) {
  const { stdout } = await exec("ffprobe", ["-v", "error", "-protocol_whitelist", "file,pipe", ...(gif ? ["-ignore_loop", "1", "-count_frames"] : []), "-show_entries", "format=format_name,duration:stream=codec_type,width,height,nb_read_frames", "-of", "json", path], { timeout: 10_000, maxBuffer: 256 * 1024 });
  return JSON.parse(stdout);
}

export class MediaStore {
  readonly limits: Limits;
  constructor(readonly root: string, limits: Partial<Limits> = {}) {
    this.limits = { ...defaults, ...limits };
    for (const key of ["maxBytes", "maxSeconds", "maxVideos", "maxRequestBytes"] as const) {
      if (!Number.isFinite(this.limits[key]) || this.limits[key] <= 0) throw new Error(`Invalid video limit: ${key}`);
    }
    if (!Number.isInteger(this.limits.maxVideos)) throw new Error("maxVideos must be an integer");
    if (!Array.isArray(this.limits.models) || !this.limits.models.every(v => typeof v === "string")) throw new Error("Invalid video models list");
  }

  async attach(source: string, cwd: string): Promise<Attachment> {
    const remote = /^[a-z]+:\/\//i.test(source);
    const path = resolve(cwd, source.startsWith("~/") ? join(homedir(), source.slice(2)) : source);
    let bytes = remote ? await download(source, this.limits.maxBytes) : await readBounded(path, this.limits.maxBytes);
    if (!bytes.length) throw new Error("Video is empty");
    const name = (remote ? basename(new URL(source).pathname) || "remote video" : basename(path)).replace(/[\x00-\x1f\x7f]/g, "?");
    await mkdir(this.root, { recursive: true, mode: 0o700 });
    const work = await mkdtemp(join(this.root, ".prepare-"));
    try {
      const input = join(work, "input.media");
      await writeFile(input, bytes, { mode: 0o600 });
      const gif = /^GIF8[79]a/.test(bytes.subarray(0, 6).toString("ascii"));
      let probe = await probeVideo(input, gif);
      let prepared = input;
      if (gif) {
        const frames = Number(probe.streams?.find((s: any) => s.codec_type === "video")?.nb_read_frames);
        if (!Number.isFinite(frames) || frames < 1) throw new Error("Cannot determine GIF frame count");
        if (frames === 1) return { id: "", text: `[Image: ${name} · static GIF]`, image: { type: "image", mimeType: "image/gif", data: bytes.toString("base64") } };
        const duration = Number(probe.format?.duration);
        if (!Number.isFinite(duration) || duration <= 0 || duration > this.limits.maxSeconds) throw new Error("GIF exceeds duration limit or has unknown duration");
        prepared = join(work, "converted.mp4");
        await exec("ffmpeg", ["-v", "error", "-nostdin", "-protocol_whitelist", "file,pipe", "-ignore_loop", "1", "-i", input, "-an", "-vf", "pad=ceil(iw/2)*2:ceil(ih/2)*2", "-fps_mode", "vfr", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", "-fs", String(this.limits.maxBytes + 1), prepared], { timeout: 20_000, maxBuffer: 256 * 1024 });
        bytes = await readBounded(prepared, this.limits.maxBytes);
        probe = await probeVideo(prepared);
        if (Math.abs(Number(probe.format?.duration) - duration) > 0.15) throw new Error("GIF conversion changed duration; attachment rejected");
      }
      if (!probe.streams?.some((s: any) => s.codec_type === "video")) throw new Error("File has no video stream");
      const format = probe.format?.format_name as string;
      const mime = format?.includes("mp4") ? "video/mp4" : format?.includes("webm") ? "video/webm" : undefined;
      if (!mime) throw new Error("Use MP4/MOV, WebM/MKV, or GIF media");
      const seconds = Number(probe.format.duration);
      if (!Number.isFinite(seconds) || seconds <= 0) throw new Error("Cannot determine video duration");
      if (seconds > this.limits.maxSeconds) throw new Error("Video exceeds the duration limit");
      const id = createHash("sha256").update(bytes).digest("hex");
      const meta: Metadata = { mime, bytes: bytes.length, seconds, name };
      await writeFile(join(work, "metadata.json"), JSON.stringify(meta), { mode: 0o600 });
      await rename(prepared, join(this.root, `${id}.media`));
      await rename(join(work, "metadata.json"), join(this.root, `${id}.json`));
      return { id, text: `[Video: ${name} · ${seconds.toFixed(2)}s · ${(bytes.length / 1024 / 1024).toFixed(2)} MiB · visual content only]\n[omp-video:${id}]` };
    } finally { await rm(work, { recursive: true, force: true }); }
  }

  async load(id: string) {
    if (!/^[a-f0-9]{64}$/.test(id)) throw new Error("Invalid video attachment ID");
    let meta: Metadata;
    let bytes: Buffer;
    try {
      meta = JSON.parse(await readFile(join(this.root, `${id}.json`), "utf8"));
      bytes = await readBounded(join(this.root, `${id}.media`), this.limits.maxBytes);
    } catch (error) {
      throw new Error(`Video attachment missing or unreadable (${id.slice(0, 8)}). Reattach the source file. ${String(error)}`);
    }
    if (bytes.length > this.limits.maxBytes || bytes.length !== meta.bytes) throw new Error("Cached video exceeds size limit or is damaged");
    if (!Number.isFinite(meta.seconds) || meta.seconds <= 0 || meta.seconds > this.limits.maxSeconds) throw new Error("Cached video exceeds duration limit or is damaged");
    if (!["video/mp4", "video/webm"].includes(meta.mime) || createHash("sha256").update(bytes).digest("hex") !== id) throw new Error("Cached video is damaged");
    return { bytes: bytes.length, url: `data:${meta.mime};base64,${bytes.toString("base64")}` };
  }
}

export async function injectVideos(payload: any, model: Model, store: MediaStore): Promise<any> {
  if (!Array.isArray(payload?.messages)) return payload;
  let count = 0;
  let total = 0;
  const messages = [];
  for (const message of payload.messages) {
    if (message.role !== "user") { messages.push(message); continue; }
    const content = typeof message.content === "string" ? [{ type: "text", text: message.content }] : message.content;
    if (!Array.isArray(content)) { messages.push(message); continue; }
    let changed = false;
    const result = [];
    for (const block of content) {
      if (block.type !== "text" || typeof block.text !== "string") { result.push(block); continue; }
      const ids = [...block.text.matchAll(marker)].map(m => m[1]);
      if (!ids.length) { result.push(block); continue; }
      assertCompatible(model, store.limits);
      changed = true;
      const text = block.text.replace(marker, "").trim();
      if (text) result.push({ ...block, text });
      for (const id of ids) {
        if (++count > store.limits.maxVideos) throw new Error("Request exceeds video count limit; start a new session or compact old video turns");
        const video = await store.load(id);
        total += video.bytes;
        if (total > store.limits.maxRequestBytes) throw new Error("Request exceeds total video size limit");
        result.push({ type: "video_url", video_url: { url: video.url } });
      }
    }
    messages.push(changed ? { ...message, content: result } : message);
  }
  return { ...payload, messages };
}
