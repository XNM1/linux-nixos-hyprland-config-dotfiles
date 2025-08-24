function night_mode_temp_up
    set target_process hyprsunset
    set temp_file ~/.cache/hyprsunset_temp
    set increment 100

    if not pgrep $target_process >/dev/null
        return
    end

    if test -f $temp_file
        set current_temp (cat $temp_file)
    else
        set current_temp 4000
    end

    set new_temp (math $current_temp + $increment)

    if test $new_temp -gt 6500
        set new_temp 6500
    end

    echo $new_temp >$temp_file

    killall -s SIGINT $target_process
    sleep 0.5
    $target_process -t $new_temp
end
