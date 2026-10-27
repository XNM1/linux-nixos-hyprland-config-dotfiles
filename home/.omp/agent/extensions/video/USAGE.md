# Video attachments for omp 18.9.1

Restart omp to discover this extension, then use:

```text
/video "/home/xnm/Videos/demo.mp4" -- Explain what happens.
/video "https://example.com/demo.webm" -- Summarize this clip.
/video "/home/xnm/Pictures/animation.gif" -- Describe the movement.
/video help
```

You can drag a file into the terminal after typing `/video `. Quoted paths and
shell-escaped spaces are supported. Add ` -- question` after the path, or omit it
to request a description.

omp also turns pasted/dragged local video paths into preview chips. These now
work directly: paste the video, type a question, and press Enter. You may also
use `/video [video chip] -- question`. The extension reads the original path
carried by omp's chip and sends the actual video instead of its contact-sheet
preview. File-backed GIF chips likewise use the original GIF, retaining motion.
Other image attachments are preserved alongside the video.

This uses omp's existing paste behavior, not a new keyboard shortcut. The
clipboard must supply the file/path for local media. A browser's copied still
frame has no recoverable video; use `/video "direct media URL" -- question` for
browser videos. Ordinary links and native `@file` attachments are not intercepted.

## Behavior

- Works in the interactive terminal, RPC sessions, and print/json one-shot mode
  (see below); in interactive/RPC the agent must be idle.
  The command sends the attachment and question immediately.
- MP4/MOV and WebM/MKV files are checked with FFprobe. Animated GIFs are converted
  to MP4 with FFmpeg, once through the animation, preserving frame timing.
  Static GIFs are submitted through omp's image support.
- HTTP(S) URLs must point to media files, not hosting pages such as YouTube.
  Downloads have a 20-second timeout and a streaming byte limit, even when the
  server doesn't supply Content-Length. The downloaded content is snapshotted.
- The transcript shows filename, duration, and size. Videos are visual input;
  this extension does not transcribe their audio or play them in the terminal.
- Native vLLM `video_url` content is added at the provider request boundary.
  vLLM decides frame sampling and visual token usage; byte/duration limits do
  not guarantee the media will fit the server's context or GPU limits.
- Print/JSON one-shot mode (`-p`, `--mode json`) works: the answer is produced
  as a single ephemeral turn inside the command, streamed to stdout (valid
  JSONL frames in json mode). The reply is not persisted to the session
  transcript, so a resumed session will not contain the video turn.
  Help and errors go to stderr to keep the stdout stream clean.

## Limits and compatibility

Edit `~/.omp/agent/video.json`; changes apply to the next attachment/request:

```json
{
  "maxBytes": 20971520,
  "maxSeconds": 60,
  "maxVideos": 2,
  "maxRequestBytes": 41943040,
  "models": ["vllm/qwen3.8-flash-next"]
}
```

Limits are 20 MiB per file, 60 seconds per video, two videos and 40 MiB of raw
video bytes per request. Base64 adds roughly one third to the wire size.
Request limits include retained conversation history. Start a new session or
compact old video turns if they exceed these limits. Videos are never silently
truncated to fit. Conversion/download/codec failures are reported as errors.

Only explicitly listed `provider/model` pairs using `openai-completions` are
enabled. The configured Qwen endpoint was verified with an actual video request.
Adding another pair is an explicit opt-in; verify that endpoint's video support
first. Switching a conversation containing videos to an unlisted model aborts
the turn with an error. `models.yml` remains `[text, image]` because the extension
handles video capability separately from omp's built-in content schema.

## Session replay and storage

The extension stores SHA-256-addressed media and metadata under
`~/.omp/agent/video-attachments/`. Transcripts contain an `omp-video` reference,
not the base64 data. Resume, retries, and retained turns resolve that reference;
the original file or URL is no longer needed. Missing or altered cached media
aborts the request rather than silently dropping the attachment.

### Automatic pruning

An entry is deleted when its `omp-video` reference appears in no session
transcript and its media file is older than 24 hours; a missing media file
counts as stale, so dangling metadata is cleaned too. The 24-hour grace period
protects attachments whose transcript a concurrent process has not flushed
yet. Media referenced by a retained transcript is never pruned.

Triggers, both async and neither blocking the attachment or the UI:

- `session_start` — every new session, `/new`, `/resume` switch, and fork.
- First successful attachment per omp process.

Cost per sweep:

| Store state | Work |
|---|---|
| Empty, or every entry younger than 24 h | One `readdir` of the store plus a `stat` per pair; transcripts are never read (~13 ms) |
| Any entry older than 24 h | Full scan of `sessions/` and `terminal-sessions/` transcripts for `omp-video` references, then unreferenced pairs are deleted |

Consequences: deleting a session frees its media at the next sweep; one-shot
(`-p`) attachments never persist a transcript, so their media is orphaned at
birth and prunable after 24 hours. Compaction can replace old video turns with
summaries, as it does for other conversation history; once the reference is
gone, the media becomes prunable too. To move sessions to another machine,
copy these attachments and install the extension there too. Session
sharing/export alone does not carry the videos.

`PI_CODING_AGENT_DIR` overrides the extension's configuration/storage root. When
using an isolated profile, set this variable to its agent directory as well.

Dependencies: `ffprobe` and `ffmpeg` (with libx264) on PATH. No omp fork or rebuild.

## Verification

```sh
bun test ~/.omp/agent/extensions/video/test
python3 ~/.omp/agent/extensions/video/test/tui-paste.py
```

Tests include bounded remote downloads, GIF motion, limits, cache integrity,
and actual installed-omp RPC requests to a local test server. They also verify
automatic extension discovery and resumed sessions without the original file,
plus print/json one-shot modes: the ephemeral `video_url` request, the stdout
reply, and parseable json frames.
The Python regression drives the installed TUI through a pseudo-terminal,
pastes a real local video to create a native chip, and verifies the outgoing
`video_url`. Chip metadata is private to omp 18.9.1; rerun this check after omp
upgrades. Missing original-path metadata is reported rather than guessed from
the current clipboard or silently replaced with a still image.
