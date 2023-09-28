function bluetooth_toggle
    set bluetooth_status (rfkill list bluetooth | grep -i -o "Soft blocked: yes")

    if [ -z "$bluetooth_status" ]
        rfkill block bluetooth
    else
        rfkill unblock bluetooth
    end
end