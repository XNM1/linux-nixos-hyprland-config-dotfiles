function dunst_pause
    set COUNT_WAITING (dunstctl count waiting)
    set COUNT_DISPLAYED (dunstctl count displayed)
    set ENABLED "{ \"text\": \"󰂜\", \"tooltip\": \"notifications <span color='#a6da95'>on</span>\", \"class\": \"on\" }"
    set DISABLED "{ \"text\": \"󰪑\", \"tooltip\": \"notifications <span color='#ee99a0'>off</span>\", \"class\": \"off\" }"
    
    if [ $COUNT_DISPLAYED != 0 ]
        set ENABLED "{ \"text\": \"󰂚$COUNT_DISPLAYED\", \"tooltip\": \"$COUNT_DISPLAYED notifications\", \"class\": \"on\" }"
    end

    if [ $COUNT_WAITING != 0 ]
        set DISABLED "{ \"text\": \"󰂛$COUNT_WAITING\", \"tooltip\": \"(silent) $COUNT_WAITING notifications\", \"class\": \"off\" }"
    end

    if dunstctl is-paused | rg -q "false"
        echo $ENABLED
    else
        echo $DISABLED
    end
end