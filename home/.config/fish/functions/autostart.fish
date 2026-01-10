function autostart
    pypr & hyprpaper & hypridle & waybar & poweralertd -s & wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store & wl-clip-persist --clipboard regular & avizo-service & systemctl --user start psi-notify
end
