import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";
import { pathToFileURL } from "node:url";
import { EventEmitter } from "node:events";

// Substitute only the process boundary; run each hook's actual handler.
function loadHook(name: string, response = { stdout: '{"results":[]}', stderr: "", error: null as any }) {
  const file = `${import.meta.dir}/../hooks/post/${name}.ts`;
  const calls: any[] = [];
  const stdin = new EventEmitter() as any;
  stdin.end = (text: string) => { stdin.text = text; };
  const execFile = (bin: string, args: string[], options: any, callback: Function) => {
    calls.push({ bin, args, options });
    if (!callback) return { ...response, status: response.error ? 1 : 0 };
    queueMicrotask(() => callback(response.error, response.stdout, response.stderr));
    return { stdin };
  };
  const source = readFileSync(file, "utf8")
    .replace(/import \{ (\w+) \} from "node:child_process";/, "const $1 = processStub;")
    .replace(/import (.*?) from (.*?);/g, "const $1 = require($2);")
    .replaceAll("import.meta.url", JSON.stringify(pathToFileURL(file).href))
    .replace("export default function", "return function");
  const factory = new Function("processStub", "require", new Bun.Transpiler({ loader: "ts" }).transformSync(source));
  const handlers: Record<string, Function> = {};
  factory(execFile, createRequire(import.meta.url))({ on: (name: string, fn: Function) => handlers[name] = fn });
  const warnings: string[] = [];
  const ctx = { cwd: "/tmp/opencode/project with spaces", hasUI: true, ui: { notify: (text: string) => warnings.push(text) } };
  return { run: (event: any) => handlers.tool_result(event, ctx), handlers, calls, stdin, warnings, ctx };
}

test("scanner handles direct-path edits in the active project", async () => {
  const h = loadHook("edit-scan");
  await h.run({ toolName: "edit", input: { path: "src/a.ts" } });
  expect(h.calls).toHaveLength(1);
  expect(h.calls[0].args.at(-1)).toBe(`${h.ctx.cwd}/src/a.ts`);
});

test("scanner handles multiple normalized paths in the active project", async () => {
  const h = loadHook("edit-scan");
  await h.run({ toolName: "edit", input: { path: "src/a.ts", paths: ["src/a.ts", "src/b space.ts"] } });
  expect(h.calls).toHaveLength(1);
  expect(h.calls[0].args.slice(-2)).toEqual([`${h.ctx.cwd}/src/a.ts`, `${h.ctx.cwd}/src/b space.ts`]);
  expect(h.calls[0].options.cwd).toBe(h.ctx.cwd);
  expect(h.calls[0].options.timeout).toBeGreaterThan(0);
  expect(h.calls[0].options.killSignal).toBe("SIGKILL");
});

test("scanner ignores unsuccessful edits and non-source files", async () => {
  const h = loadHook("edit-scan");
  await h.run({ toolName: "edit", isError: true, input: { path: "a.ts" } });
  await h.run({ toolName: "write", input: { path: "README.md" } });
  expect(h.calls).toHaveLength(0);
});

test("scanner warns once on failure, then resets for a new session", async () => {
  const h = loadHook("edit-scan", { stdout: "", stderr: "", error: new Error("missing executable") });
  const event = { toolName: "write", input: { path: "a.ts" } };
  await h.run(event);
  await h.run(event);
  expect(h.warnings).toHaveLength(1);
  h.handlers.session_switch();
  await h.run(event);
  expect(h.warnings).toHaveLength(2);
});

test("scanner reports JSON errors and keeps findings out of instruction context", async () => {
  const h = loadHook("edit-scan", { stdout: JSON.stringify({ errors: [{}], results: [{ path: "a.ts", check_id: "test.rule", start: { line: 2 } }] }), stderr: "", error: null });
  const result = await h.run({ toolName: "write", input: { path: "a.ts" }, content: [{ type: "text", text: "written" }] });
  expect(h.warnings).toHaveLength(1);
  expect(result.content[0].text).toBe("written");
  expect(result.content[1].text).toContain("test.rule");
  expect(result.additionalContext).toBeUndefined();
});

test("compression runs asynchronously with a deadline and preserves errors", async () => {
  const h = loadHook("bash-shrink", { stdout: "compressed", stderr: '{"recovery_handle":"abc"}', error: null });
  const event = { toolName: "bash", content: [{ type: "text", text: "x".repeat(4000) }] };
  const result = await h.run(event);
  expect(h.calls[0].options.timeout).toBeGreaterThan(0);
  expect(h.calls[0].options.killSignal).toBe("SIGKILL");
  expect(h.stdin.text).toBe(event.content[0].text);
  expect(result.content[0].text).toContain("caveman retrieve abc");
  expect(await h.run({ ...event, isError: true })).toBeUndefined();
  expect(h.calls).toHaveLength(1);
});

test("compression failure keeps the original result and tolerates closed stdin", async () => {
  const h = loadHook("bash-shrink", { stdout: "partial", stderr: "", error: new Error("timeout") });
  expect(await h.run({ toolName: "bash", content: [{ type: "text", text: "x".repeat(4000) }] })).toBeUndefined();
  expect(() => h.stdin.emit("error", new Error("EPIPE"))).not.toThrow();
});
