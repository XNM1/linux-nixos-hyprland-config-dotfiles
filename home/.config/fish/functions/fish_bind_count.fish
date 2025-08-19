function fish_bind_count
    argparse 'h/help' 'z/zero' 'r/read' -- $argv
    or return 1
    if test -n "$_flag_help"
        echo "Helper function to track count modifier with modal key bindings"
        echo "Usage: $0 [-h] [-z] [DIGITS ...]"
        return
    end
    if test -n "$_flag_zero" || not string match -rq '[1-9]\d*' "$fish_bind_count"
        set -g fish_bind_count 0
    end
    # Iterate over given digits
    for arg in $argv
        for digit in (string split '' "$arg")
            set -g fish_bind_count $(math "$fish_bind_count" \* 10 \+ "$digit")
        end
    end
    if test -n "$_flag_read"
        set -l count "$fish_bind_count"
        set -g fish_bind_count 0
        if test "$count" = 0
            echo 1
            return 1
        else
            echo "$count"
        end
    end
end