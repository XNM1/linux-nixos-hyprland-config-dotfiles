function check_recording
    set target_process "wf-recorder"
    
    if pgrep $target_process > /dev/null
        echo "{\"text\":\"\", \"tooltip\":\"Recording\", \"alt\":\"Recording\"}"
    end
end