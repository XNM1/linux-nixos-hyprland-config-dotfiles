function check_airplane_mode
    set backup_file ~/.cache/airplane_backup

    if test -e $backup_file
        echo "{ \"text\":\"󰀝\", \"tooltip\": \"airplane-mode <span color='#a6da95'>on</span>\", \"class\": \"on\" }"
    else
        echo "{ \"text\":\"󰀞\", \"tooltip\": \"airplane-mode <span color='#ee99a0'>off</span>\", \"class\": \"off\" }"
    end
end