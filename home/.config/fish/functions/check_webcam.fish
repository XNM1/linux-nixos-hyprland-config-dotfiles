function check_webcam
    set process_pids (fuser /dev/video0 | awk '{print $2}' | sort -u)
    if test -n "$process_pids"
        set processes ""
        for process_pid in $process_pids
            set process_name (ps -q $process_pid -o comm=)
            set processes "$processes\n<span color='#eed49f'>$process_name($process_pid)</span>"
        end
        echo "{\"text\":\"󰖠\", \"tooltip\":\"webcam is used by: $processes\", \"alt\":\"Webcam\"}"
    end
end
