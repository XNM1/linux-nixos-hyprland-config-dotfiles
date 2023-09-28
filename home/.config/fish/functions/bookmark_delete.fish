function bookmark_delete
    set bookmark $(cat .bookmarks | rofi -dmenu -p 'delete bookmark')
    if not [ -z $bookmark ]
        sed -i -e /$bookmark/d .bookmarks
        dunstify "Bookmarks" "Bookmark '$bookmark' was deleted" -t 2000
    end
end