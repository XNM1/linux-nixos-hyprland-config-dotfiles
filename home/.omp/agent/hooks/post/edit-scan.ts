// Scan edited source files without blocking the terminal; findings remain tool output.
import { execFile } from "node:child_process";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const BIN = "opengrep";
// Snapshot of https://semgrep.dev/c/p/security-audit; no registry fetch in the edit loop.
const CONFIG = fileURLToPath(new URL("../../cache/opengrep-security-audit.yaml", import.meta.url));
const TIMEOUT_MS = 8000;
const MAX_FINDINGS = 8;
const SRC_EXT = /\.(ts|tsx|js|jsx|mjs|cjs|py|rs|go|java|kt|c|h|cpp|hpp|cc|rb|php|cs|swift|scala|lua|bash|sh|ocaml|nix)$/i;
interface ToolResultEvent {
  toolName: string;
  isError: boolean;
  input?: Record<string, unknown>;
  content: unknown[];
}
interface Context {
  cwd: string;
  hasUI: boolean;
  ui: { notify(message: string, type: string): void };
}
interface PiApi { on(event: string, handler: (ev: unknown, ctx: Context) => unknown): void }

function touchedFiles(ev: ToolResultEvent, cwd: string): string[] {
  if (!["write", "edit", "multiedit"].includes(ev.toolName)) return [];
  // OMP normalizes hashline and patch targets into path/paths before emitting tool_result.
  const paths = [ev.input?.path, ...(Array.isArray(ev.input?.paths) ? ev.input.paths : [])];
  return [...new Set(paths.filter((p): p is string => typeof p === "string" && SRC_EXT.test(p))
    .map(p => resolve(cwd, p)))];
}

export default function (pi: PiApi): void {
  let warned = false;
  for (const event of ["session_start", "session_switch"]) pi.on(event, () => { warned = false; });
  function warn(ctx: Context) {
    if (warned) return;
    warned = true;
    const message = `Opengrep scan failed or was incomplete. Check the executable and rules: ${CONFIG}`;
    if (ctx.hasUI) ctx.ui.notify(message, "warning");
    else console.error(message);
  }
  pi.on("tool_result", async (raw, ctx) => {
    const ev = raw as ToolResultEvent;
    if (ev.isError) return;
    const files = touchedFiles(ev, ctx.cwd);
    if (!files.length) return;

    const r = await new Promise<{ stdout: string; failed: boolean }>((done) => {
      execFile(BIN,
        ["scan", "--json", "--quiet", "--disable-version-check", "--timeout", "2",
          "--max-target-bytes", "400000", "--config", CONFIG, "--", ...files],
        { cwd: ctx.cwd, encoding: "utf8", timeout: TIMEOUT_MS, killSignal: "SIGKILL", maxBuffer: 16 * 1024 * 1024 },
        (error, stdout) => done({ stdout, failed: !!error }));
    });
    if (r.failed) { warn(ctx); return; }
    try {
      const json = JSON.parse(r.stdout);
      if (!Array.isArray(json.results)) { warn(ctx); return; }
      if (json.errors?.length) warn(ctx);
      const hits = json.results;
      if (!hits.length) return;
      const lines = hits.slice(0, MAX_FINDINGS)
        .map((h: { path: string; check_id: string; start?: { line?: number } }) =>
          `${h.path}:${h.start?.line ?? "?"} ${h.check_id}`).join("\n");
      const more = hits.length > MAX_FINDINGS ? `\n(+${hits.length - MAX_FINDINGS} more)` : "";
      return { content: [...ev.content, { type: "text", text: `opengrep on edited files:\n${lines}${more}` }] };
    } catch { warn(ctx); }
  });
}
