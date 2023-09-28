function bookmark_to_type
    cat .bookmarks | rofi -dmenu -p bookmarks | tr -d '\n' | wtype -
end