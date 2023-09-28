function night_mode_toggle
    set target_process "gammastep"
    
    if pgrep $target_process > /dev/null
        killall -s SIGINT .gammastep-wrap
    else
        gammastep
    end
end