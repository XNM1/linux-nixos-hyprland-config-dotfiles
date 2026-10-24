function aichat_suggest --description "LLM command suggestions via fzf (Ctrl+Space)"
    set -l st $status
    set -l buf (commandline | string collect)

    # Empty prompt after a failed command: pay-respects handles the fix.
    if test -z "$buf"; and test $st -ne 0
        functions -q __pr_main; and __pr_main suggest
        return
    end

    set -l prefix (string trim --left -- "$buf")
    set -l context "Complete this fish command prefix, preserving it exactly: <$prefix>"
    if test -z "$prefix"
        set context 'Suggest likely next commands based on recent history.'
    end
    set context "$context

Recent history (supporting context only):
$(history --max=5 | string collect)"
    set -l out (__aichat_request -c --prompt 'Suggest up to 5 fish shell commands. If a command prefix is supplied, every suggestion must start with that exact prefix; complete it rather than switching to another command. Use recent history only to inform relevant completions, never to override the prefix. With no prefix, suggest likely next commands from history. Reply with complete commands, one per line, no numbering, no markdown, no comments.' -- "$context")
    or return
    set out (string match -r '\S.*' -- $out)
    # Enforce the prefix locally even if the model ignores the instruction.
    if test -n "$prefix"
        set -l pattern (string escape --style=regex -- "$prefix")
        set out (string match -r -- "^$pattern.*" $out)
    end
    test (count $out) -gt 0; or return

    set -l pick (printf '%s\n' $out | fzf --prompt 'ai> ' --height 40% --reverse)
    and test -n "$pick"; and commandline --replace -- "$pick"
    commandline --function repaint
end
