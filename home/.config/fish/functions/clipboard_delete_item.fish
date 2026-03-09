function clipboard_delete_item
    set -l clip (cliphist list | rofi -dmenu -p 'clipboard delete item')

    if test -n "$clip"
        printf '%s\n' "$clip" | cliphist delete
        dunstify Clipboard "Clip '$clip' was deleted" -t 2000
    end
end
