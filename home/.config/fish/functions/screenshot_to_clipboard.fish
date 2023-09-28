function screenshot_to_clipboard
    set screenshot_filename (echo "$HOME/Pictures/Screenshots/screenshot-$(date +"%Y-%m-%d--%H:%M:%S").png")
    grim -g (slurp) $screenshot_filename

    if [ -e $screenshot_filename ]
        cat $screenshot_filename | wl-copy --type image/png
        dunstify -i $screenshot_filename -r (cd ~/Pictures/Screenshots/ && ls -1 | wc -l) "Screenshots" "Screenshot was taken" -t 2000
    end
end