function wifi_toggle
    set wifi_status (nmcli radio wifi)
    set backup_file ~/.cache/airplane_backup

    if [ "$wifi_status" = enabled ]
        nmcli radio wifi off
    else
        nmcli radio wifi on
        if test -e $backup_file
            rm $backup_file
        end
    end
end
