function bluetooth_toggle
    set bluetooth_status (rfkill list bluetooth | grep -i -o "Soft blocked: yes")
    set backup_file ~/.cache/airplane_backup

    if [ -z "$bluetooth_status" ]
        rfkill block bluetooth
    else
        rfkill unblock bluetooth
        if test -e $backup_file
            rm $backup_file
        end
    end
end
