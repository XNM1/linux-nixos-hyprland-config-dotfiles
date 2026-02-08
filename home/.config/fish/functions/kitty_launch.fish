function kitty_launch
    for f in /sys/class/power_supply/*/online
        if test (cat $f 2>/dev/null) = "1"
            nvidia-offload kitty $argv
            return
        end
    end
    kitty $argv
end
