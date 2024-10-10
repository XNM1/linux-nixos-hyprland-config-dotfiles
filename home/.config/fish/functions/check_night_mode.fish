function check_night_mode
    set target_process wlsunset

    if pgrep $target_process >/dev/null
        echo "{ \"text\":\"󱩌\", \"tooltip\": \"night-mode <span color='#a6da95'>on</span>\", \"class\": \"on\" }"
    else
        echo "{ \"text\":\"󱩍\", \"tooltip\": \"night-mode <span color='#ee99a0'>off</span>\", \"class\": \"off\" }"
    end
end
