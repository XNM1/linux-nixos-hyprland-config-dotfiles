import type { ImageContent } from "@oh-my-pi/pi-ai";
import { assertCompatible, type MediaStore } from "./media";

type Input = { text: string; images?: ImageContent[] };
const visionMarker = /\[(Image|Video) #(\d+)(, [^\]\r\n]*)?\]/g;

function originalSource(image: ImageContent): { path: string; kind: string } | undefined {
  // omp 18.9.1 preserves this symbol on draft images passed to the input hook.
  // It is private (not Symbol.for or a public extension export), so importing a
  // second copy would not match the symbol in omp's compiled executable.
  for (const symbol of Object.getOwnPropertySymbols(image)) {
    if (symbol.description !== "image.attachmentSource") continue;
    const value = (image as any)[symbol];
    if (value && typeof value.path === "string" && (value.kind === "video" || value.kind === "image")) return value;
  }
}

/** Resolve native preview chips before slash-command parsing loses their images. */
export async function transformVideoInput(
  event: Input,
  model: Parameters<typeof assertCompatible>[0],
  media: Pick<MediaStore, "attach" | "limits">,
  cwd: string,
): Promise<Input | undefined> {
  const text = event.text.trim();
  const command = /^\/video(?:\s|$)/.test(text);
  if (text.startsWith("/") && !command) return;
  const sources = (event.images ?? []).map(image => {
    const source = originalSource(image);
    return source && (source.kind === "video" || /\.gif$/i.test(source.path)) ? source.path : undefined;
  });
  const references = [...text.matchAll(visionMarker)];
  for (const match of references) {
    if (match[1] === "Video" && !sources[Number(match[2]) - 1]) {
      throw new Error('Cannot recover the original video path from this preview. Re-paste the video file or use /video "absolute/path.mp4" -- question.');
    }
  }
  if (!sources.some(Boolean)) return;
  assertCompatible(model, media.limits);
  if (sources.filter(Boolean).length > media.limits.maxVideos) throw new Error("Attachment video count limit exceeded");

  const images: ImageContent[] = [];
  const replacements = new Map<number, { image?: number; video?: number }>();
  const attachments: string[] = [];
  for (const [index, image] of (event.images ?? []).entries()) {
    const source = sources[index];
    if (!source) {
      images.push(image);
      replacements.set(index + 1, { image: images.length });
      continue;
    }
    const attachment = await media.attach(source, cwd);
    if (attachment.image) {
      images.push(attachment.image);
      replacements.set(index + 1, { image: images.length });
    } else {
      attachments.push(`[Attached video ${attachments.length + 1}]\n${attachment.text}`);
      replacements.set(index + 1, { video: attachments.length });
    }
  }
  const body = command ? text.replace(/^\/video\s*/, "") : text;
  let prompt = body.replace(visionMarker, (whole, _kind, number, dims = "") => {
    const replacement = replacements.get(Number(number));
    if (!replacement) return whole;
    if (replacement.image) return `[Image #${replacement.image}${dims}]`;
    return command ? "" : `[Attached video ${replacement.video}]`;
  }).trim();
  if (command) prompt = prompt.replace(/^--\s*/, "").trim();
  if (!prompt || (!command && !body.replace(visionMarker, "").trim())) prompt = "Describe what happens in this video.";
  return { text: [prompt, ...attachments].join("\n\n"), images };
}
