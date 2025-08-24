function night_mode_temp_down
    set target_process hyprsunset
    set temp_file ~/.cache/hyprsunset_temp
    set decrement 100

    if not pgrep $target_process >/dev/null
        return
    end

    if test -f $temp_file
        set current_temp (cat $temp_file)
    else
        set current_temp 4000
    end

    set new_temp (math $current_temp - $decrement)

    if test $new_temp -lt 2000
        set new_temp 2000
    end

    echo $new_temp >$temp_file

    killall -s SIGINT $target_process
    sleep 0.5
    $target_process -t $new_temp
end
