function check_recording
    set target_process wl-screenrec

    if pgrep $target_process >/dev/null
        echo "{\"text\":\"\", \"tooltip\":\"Recording\", \"alt\":\"Recording\"}"
    end
end
