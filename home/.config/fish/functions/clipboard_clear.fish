function clipboard_clear
    rm "$HOME/.cache/cliphist/db"
    dunstify Clipboard Cleared -t 2000
end
