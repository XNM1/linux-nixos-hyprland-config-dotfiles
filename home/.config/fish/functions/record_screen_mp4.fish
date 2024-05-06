function record_screen_mp4
    set target_process wl-screenrec

    if pgrep $target_process >/dev/null
        killall -s SIGINT $target_process
    else
        set geometry (slurp)
        if not [ -z $geometry ]
            set record_name $(echo "recrod-$(date +"%Y-%m-%d--%H:%M:%S")")
            dunstify -i ~/.config/fish/icons/camera_mp4_icon.png -r $(cd ~/Videos/Records/ && ls -1 | wc -l) "Recording Started  (MP4)" -t 2000
            wl-screenrec -g "$geometry" -f "$HOME/Videos/Records/$record_name.mp4"
            wl-copy -t text/uri-list file://$HOME/Videos/Records/$record_name.mp4\n
            dunstify -i ~/.config/fish/icons/camera_mp4_icon.png -r $(cd ~/Videos/Records/ && ls -1 | wc -l) "Recording Stopped 󰙧 (MP4)" -t 2000
        end
    end
end
