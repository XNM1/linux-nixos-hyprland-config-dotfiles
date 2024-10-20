function wifi_toggle
    set wifi_status (rfkill list wifi | grep -i -o "Soft blocked: yes")
    set backup_file ~/.cache/airplane_backup

    if [ -z "$wifi_status" ]
        rfkill block wifi
    else
        rfkill unblock wifi
        if test -e $backup_file
            rm $backup_file
        end
    end
end
