import { expect, test } from "bun:test";
import init from "../../caveman-plugin/index.cjs";

function setup() {
  const handlers: Record<string, Function> = {};
  const commands: Record<string, any> = {};
  const entries: any[] = [];
  let status: string | undefined;
  const ctx = { sessionManager: { getBranch: () => entries }, ui: { setStatus: (_: string, value?: string) => status = value, notify() {} } };
  init({ on: (name: string, fn: Function) => handlers[name] = fn, registerCommand: (name: string, cmd: any) => commands[name] = cmd, appendEntry: (customType: string, data: any) => entries.push({ type: "custom", customType, data }) });
  return { handlers, commands, entries, ctx, status: () => status };
}

test("normal mode persists, removes active rules, and restores on resume", async () => {
  const h = setup();
  await h.handlers.session_start({}, h.ctx);
  const active = await h.handlers.before_agent_start({ systemPrompt: ["base"] });
  await h.handlers.input?.({ text: "normal mode", source: "interactive" }, h.ctx);
  expect(h.status()).toBeUndefined();
  expect(h.entries.at(-1)?.data.mode).toBe("off");
  expect((await h.handlers.before_agent_start(active)).systemPrompt).toEqual(["base"]);
  await h.handlers.session_switch({}, h.ctx);
  expect(h.status()).toBeUndefined();
  h.entries.length = 0;
  await h.handlers.session_switch({}, h.ctx);
  expect(h.status()).toBe("CAVEMAN");
});

test("commands can disable and re-enable; status does not activate", async () => {
  const h = setup();
  expect(h.commands.caveman).toBeDefined();
  await h.commands.caveman.handler("off", h.ctx);
  await h.commands.caveman.handler("status", h.ctx);
  expect(h.status()).toBeUndefined();
  await h.commands.caveman.handler("", h.ctx);
  expect(h.status()).toBe("CAVEMAN");
});
