function aichat_fish --description "Comment to command and command to comment (Ctrl+P)"
    set -l buf (commandline | string collect)
    string match -qr '\S' -- "$buf"; or return

    # Attach real files mentioned on the line, like fish-ai did.
    set -l files
    set -l input (string replace -r '^\s*#\s*' '' -- "$buf" | string collect)
    for t in (commandline --tokens-expanded --input="$input")
        test -n "$t"; or continue
        string match -q -- '-*' $t; and continue
        test -f $t; and set -a files -f $t
    end

    set -l args -e
    if not string match -qr '^\s*#' -- "$buf"
        set args -c --prompt 'Convert the shell command into one concise shell comment. Reply exactly one line starting with #, no markdown.'
    end
    set -l output (__aichat_request $args $files -- "$buf" | string collect)
    test $pipestatus[1] -eq 0; and test -n "$output"; and commandline --replace -- "$output"
end
