function bookmark_add
    set -l bookmark (wl-paste)

    if test -z "$bookmark"
        dunstify Bookmarks "Can`t add empty space" -u critical -t 2000
    else if grep -Fxq -- "$bookmark" .bookmarks
        dunstify Bookmarks "Bookmark '$bookmark' already exists" -u critical -t 2000
    else
        printf '%s\n' "$bookmark" >>.bookmarks

        dunstify Bookmarks "Bookmark '$bookmark' was added" -t 2000
    end
end
