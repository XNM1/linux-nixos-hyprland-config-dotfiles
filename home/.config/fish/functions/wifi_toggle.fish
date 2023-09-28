function wifi_toggle
    set wifi_status (nmcli radio wifi)

    if [ "$wifi_status" = "enabled" ]
        nmcli radio wifi off
    else
        nmcli radio wifi on
    end
end