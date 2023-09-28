function bookmark_add
    if [ -z $(wl-paste) ]
        dunstify "Bookmarks" "Can`t add empty space" -u critical -t 2000
    else if grep -q "^$(wl-paste)\$" .bookmarks
        dunstify "Bookmarks" "Bookmark '$(wl-paste)' already exists" -u critical -t 2000
    else
        wl-paste >> .bookmarks;
        dunstify "Bookmarks" "Bookmark '$(wl-paste)' was added" -t 2000
    end
end