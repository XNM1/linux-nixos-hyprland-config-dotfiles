#!/usr/bin/env fish
# Open TARGET (path, optionally path:line) in the Helix instance of the
# current herdr workspace. Called by lazygit's os.edit / os.editAtLine when
# HERDR_ENV=1 (mirrors the zellij branch of this config).
#
# 1. Reuses an editor tab running helix: sends Esc + :open TARGET + Enter.
# 2. Editor tab without helix: runs hx TARGET in its first pane.
# 3. No editor tab: creates one (focused, labeled "editor") and starts
#    helix on TARGET in it.

set -l target $argv[1]
test -n "$target"; or exit 1
test -n "$HERDR_WORKSPACE_ID"; or exit 1

set -l editor_tab (herdr tab list --workspace "$HERDR_WORKSPACE_ID" | jq -r \
	'[.result.tabs[] | select(.label == "editor") | .tab_id][0] // empty')

set -l pane ""
set -l helix no
if test -n "$editor_tab"
	set -l panes (herdr pane list --workspace "$HERDR_WORKSPACE_ID" | jq -r \
		--arg tab "$editor_tab" '.result.panes[] | select(.tab_id == $tab) | .pane_id')
	for p in $panes
		test -n "$pane"; or set pane $p
		if herdr pane process-info --pane $p | jq -e \
			'[(.result.process_info.foreground_processes // [])[]
			  | ((.name // ""), (.cmdline // ""), ((.argv // [""])[0] // "")) | sub(".*/"; "")]
			 | (index("hx") or index(".hx-wrapped") or index("helix"))' >/dev/null
			set pane $p
			set helix yes
			break
		end
	end
end

if test -z "$pane"
	set -l created (herdr tab create --workspace "$HERDR_WORKSPACE_ID" --label editor --cwd "$PWD" --focus)
	set pane (echo "$created" | jq -r '.result.root_pane.pane_id')
	herdr pane run "$pane" "hx "(string escape -- "$target")
else if test "$helix" = yes
	herdr tab focus "$editor_tab"
	if test "$TUIOS_ENV" = 1
		# tuios's herdr shim types with a bracketed paste, which helix
		# inserts as buffer text instead of running as :open keys.
		# Type natively; -w takes the 8-hex short id from the pane id
		# (w<session>:p<window-uuid-no-dashes>) and -s defaults to this
		# pane's session.
		set -l win (string replace -r '.*:p' '' -- "$pane" | string sub -l 8)
		tuios send-keys -w "$win" Escape
		sleep 0.05
		tuios send-text -w "$win" ":open $target"
		tuios send-keys -w "$win" Enter
	else
		herdr pane send-keys "$pane" esc
		sleep 0.05
		herdr pane send-text "$pane" ":open $target"
		herdr pane send-keys "$pane" enter
	end
else
	herdr tab focus "$editor_tab"
	herdr pane run "$pane" "hx "(string escape -- "$target")
end
