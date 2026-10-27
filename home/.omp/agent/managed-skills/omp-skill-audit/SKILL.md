---
name: omp-skill-audit
description: "Audit, dedupe, and re-provision omp agent skills (plugin vs tracked install) to cut system-prompt token cost."
---

# omp skill audit

Cut redundant skills and give the rest a real update route.

## 1. Enumerate what is actually loaded

`omp skills list` (tab-separated `name<TAB>description`). Descriptor cost of the whole block = `sum((len(name)+len(desc)+12)//4)` tokens — that block rides EVERY request.

Find every source on disk:

```bash
find ~/.omp ~/.claude ~/.codex ~/.agents -maxdepth 8 -name SKILL.md | sed 's|/SKILL.md$||'
```

omp loads only `<root>/<name>/SKILL.md` (one level, never recursive), so nested categories like `skills/<group>/<skill>/SKILL.md` need a plugin manifest, not a copy. Priority: native `.omp` (100) > skillshare (95) > omp-plugins (90) > claude (80) > `agents`/`~/.agents/skills` (70) > managed-skills (5).

## 2. Recover provenance

- `~/.agents/.skill-lock.json` (`skills.<name>.source`): Vercel skills CLI installs, updateable with `npx skills update -g`.
- `omp plugin marketplace list` + `~/.omp/plugins/cache/plugins/*`: plugin installs, update with `omp plugin marketplace update`.
- Everything else = untracked copy, cannot be updated.

## 3. Classify each skill

| Verdict | Test |
|---|---|
| non-usable | skill needs a binary/MCP that is absent (`command -v` for the commands in its code fences) |
| duplicated | another loaded skill or an omp built-in covers it (e.g. `xd://lsp` wrappers, `learn` vs a lessons skill, Ponytail vs an entropy skill) |
| stale | upstream renamed/rewrote it — compare local dir name against the upstream `git/trees/HEAD?recursive=1` listing |
| heavy | description > ~500 chars: it is pure per-request tax |

## 4. Re-provision, do not hand-edit

- Whole payload wanted → `omp plugin marketplace add <owner>/<repo>` then `omp plugin install <plugin>@<marketplace>`.
- Subset wanted → `npx skills add <owner>/<repo> -g -y -s <comma,names>` (omp is not a valid `-a` agent; the shared store `~/.agents/skills` is read via the `agents` provider).
- Remove with `npx skills remove -g -y <names>`, then prune `~/.agents/.skill-lock.json` entries whose directory is gone, and grep kept `SKILL.md` files for pointers to deleted skills.

## 5. Verify

`omp skills list | wc -l`, recount descriptor tokens, `find ~/.agents/skills ~/.claude/skills ~/.codex/skills -xtype l` for broken agent links. Active sessions need `/reload-plugins` to see the change.
