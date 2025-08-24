function night_mode_toggle
    set target_process hyprsunset
    set temp_file ~/.cache/hyprsunset_temp

    if pgrep $target_process >/dev/null
        killall -s SIGINT $target_process
    else
        if test -f $temp_file
            set temp (cat $temp_file)
        else
            set temp 4000
            echo $temp >$temp_file
        end
        $target_process -t $temp
    end
end
