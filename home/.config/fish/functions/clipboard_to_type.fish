function clipboard_to_type
    cliphist list | rofi -dmenu -p clipboard | cliphist decode | wtype -
end
