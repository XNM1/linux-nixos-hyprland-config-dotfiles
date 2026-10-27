---
name: nixos-dotfiles-commit-split
description: "Split staged changes into signed logical commits in the linux-nixos-hyprland-config-dotfiles repo: repo message format, YubiKey signing prompts, gitleaks gate, hunk-level splitting."
---

# Dotfiles commit split workflow

Repo: `~/projects/linux-nixos-hyprland-config-dotfiles`. Trigger: user says "do it again with new staged changes" or asks to split staged changes into commits.

## Steps
1. `git status --short` + `git diff --cached --stat`; read full staged diff (`artifact://` when compressed). Unstaged/untracked = user's; never touch. Never commit during a stopped rebase — check `git status`/reflog first.
2. Plan 1–2 logical commits per coherent feature (user dislikes commit sprawl). Shared files (README.md, *.example, config.fish) split by hunk so each commit holds only its feature's lines and docs: `git add -p`, or craft a minimal patch and `git apply --cached` (adjacent added lines can't be split by `git add -p` split).
3. `git reset <base-commit>` FIRST — a bare `git reset` only refreshes the index and silently diffs against the wrong base. Then per commit: stage its part, ask the user to have the YubiKey ready (SSH key `~/.ssh/github_xnm1.pub` re-signs on every commit AND every amend; gpg.format=ssh), `git commit -F <msgfile>`.
4. Message format from repo history: `type(scope): <emoji> subject` — feat ✨, fix 🐛, chore 🔧; scope = tool area (nixos, fish, aichat, hypr, fabric, lazygit...). Body: bullets immediately (no lead-in restating subject), ≤72 cols, backtick paths/options, optional closing impact line. Use `printf '%s\n' ... > /tmp/x.msg` (heredoc `MSG` inline on the terminator line breaks the shell wrapper).
5. Hook gate: lefthook pre-commit runs `gitleaks git --pre-commit --redact --staged --verbose`. On failure: STOP, do not retry/commit creds, notify user immediately.
6. Verify: `git log --show-signature` (expect `Good "git" signature ... ED25519-SK` + `G`), `git status` shows only pre-existing untracked dirs. Message-only fix: `git commit --amend --no-verify -F ...` (content unchanged, gitleaks skip safe).

## Re-splitting already-made commits (worktree-safe)
`git reset <base>` (mixed), then partial-stage WITHOUT touching the worktree: build intermediate file content, `git hash-object -w -- <tmpfile>` + `git update-index --cacheinfo 100644,<sha>,<path>` (`git hash-object -` rejects stdin redirect on this git; use a temp file). Finish with whole `git add` of remaining files per commit. Prove purity: final tree must satisfy `git diff <old-tip> HEAD` == empty.

## Pitfalls
- Commit 1 subject emoji must match type (chore=🔧, not 🐛); amend + second YubiKey touch to fix.
- `MM` files: stage only the user's staged hunk via crafted patch, leave newer worktree edits.
- Mangled history after a user re-sign rebase: `git rebase --abort` restores orig-head and re-applies autostash (`cat .git/rebase-merge/orig-head`, `.git/rebase-merge/autostash`).
- Check `git status -sb` ahead/behind before rewriting history: unpushed only is safe.
