function clipboard_to_wlcopy
    set clip $(cliphist list | rofi -dmenu -p 'clipboard copy')
    if not [ -z $clip ]
        echo $clip | cliphist decode | wl-copy
        dunstify "Clipboard" "Clip '$clip' was copied" -t 2000
    end
end