function airplane_mode_toggle
    set backup_file ~/.cache/airplane_backup

    if test -e $backup_file
        # Read network states from the backup file
        set -l wifi_status (cat $backup_file | grep -o 'wifi:\(on\|off\)$' | cut -d':' -f2)
        set -l bluetooth_status (cat $backup_file | grep -o 'bluetooth:\(on\|off\)$' | cut -d':' -f2)

        # Restore network states
        if test "$wifi_status" = on
            rfkill unblock wifi
            # else
            #     rfkill block wifi
        end

        if test "$bluetooth_status" = on
            rfkill unblock bluetooth
            # else
            #     rfkill block bluetooth
        end

        # Remove the backup file
        rm $backup_file
    else
        # Backup the current network states and turn off all networks
        echo "wifi:$(rfkill list wifi | grep -q "Soft blocked: no" && echo "on" || echo "off")" >$backup_file
        echo "bluetooth:$(rfkill list bluetooth | grep -qi "Soft blocked: no" && echo "on" || echo "off")" >>$backup_file
        # Add more lines to backup other network types if needed

        rfkill block wifi
        rfkill block bluetooth
    end
end
