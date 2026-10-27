import { expect, test } from "bun:test";
import extension from "../index";

test("registers video command and aborts incompatible replay rather than dropping media", async () => {
  const handlers = new Map<string, Function>();
  const commands = new Map<string, any>();
  extension({ on: (name: string, handler: Function) => handlers.set(name, handler), registerCommand: (name: string, spec: any) => commands.set(name, spec) } as any);
  expect(commands.has("video")).toBe(true);
  let aborted = false;
  const ctx = { hasUI: true, model: { provider: "openai", id: "text", api: "openai-responses" }, abort: () => { aborted = true; }, ui: { notify() {} } };
  await handlers.get("context")!({ messages: [{ role: "user", content: `[omp-video:${"a".repeat(64)}]` }] }, ctx);
  expect(aborted).toBe(true);
});
