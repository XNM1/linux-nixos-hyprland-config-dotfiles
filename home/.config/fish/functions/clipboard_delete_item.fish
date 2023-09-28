function clipboard_delete_item
    set clip $(cliphist list | rofi -dmenu -p 'clipboard delete item')
    if not [ -z $clip ]
        echo $clip | cliphist delete
        dunstify "Clipboard" "Clip '$clip' was deleted" -t 2000
    end
end