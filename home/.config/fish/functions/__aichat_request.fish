function __aichat_request --description "Run AIChat with progress and preserve its exit status"
    # gum renders on stderr, leaving stdout clean for command substitution.
    set -l output (gum spin --title 'thinking…' --show-stdout --show-error -- aichat $argv)
    set -l result $status
    commandline --function repaint
    if test $result -ne 0
        test -z "$output"; or printf '%s\n' $output >&2
        return $result
    end
    printf '%s\n' $output
end
