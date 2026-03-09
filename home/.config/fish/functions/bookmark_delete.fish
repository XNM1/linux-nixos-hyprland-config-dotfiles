function bookmark_delete
    set -l bookmark (rofi -dmenu -p 'delete bookmark' <.bookmarks)

    if test -n "$bookmark"
        set -l temp_file (mktemp)

        while read -l line
            if test "$line" != "$bookmark"
                printf '%s\n' "$line" >>"$temp_file"
            end
        end <.bookmarks

        mv "$temp_file" .bookmarks
        dunstify Bookmarks "Bookmark '$bookmark' was deleted" -t 2000
    end
end
