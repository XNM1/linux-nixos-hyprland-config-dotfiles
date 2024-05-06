function record_screen_gif
    set target_process wl-screenrec

    if pgrep $target_process >/dev/null
        killall -s SIGINT $target_process
    else
        set geometry (slurp)
        if not [ -z $geometry ]
            set record_name $(echo "recrod-$(date +"%Y-%m-%d--%H:%M:%S")")
            dunstify -i ~/.config/fish/icons/camera_gif_icon.png -r $(cd ~/Pictures/Records/ && ls -1 | wc -l) "Recording Started  (GIF)" -t 2000
            wl-screenrec -g "$geometry" -f "$HOME/Pictures/Records/$record_name.mp4" --encode-resolution 1920x1080
            ffmpeg -i "$HOME/Pictures/Records/$record_name.mp4" "$HOME/Pictures/Records/$record_name.gif"
            rm "$HOME/Pictures/Records/$record_name.mp4"
            wl-copy -t text/uri-list file://$HOME/Pictures/Records/$record_name.gif\n
            dunstify -i ~/.config/fish/icons/camera_gif_icon.png -r $(cd ~/Pictures/Records/ && ls -1 | wc -l) "Recording Stopped 󰙧 (GIF)" -t 2000
        end
    end
end
