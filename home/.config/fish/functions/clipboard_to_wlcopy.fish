function clipboard_to_wlcopy
    set -l clip (cliphist list | rofi -dmenu -p 'clipboard copy')

    if test -n "$clip"
        printf '%s\n' "$clip" | cliphist decode | wl-copy
        dunstify Clipboard "Clip '$clip' was copied" -t 2000
    end
end
