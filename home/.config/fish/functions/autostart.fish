function autostart
    pypr & hyprpaper & waybar & poweralertd -s & wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store & wl-clip-persist --clipboard regular & avizo-service & systemctl --user start psi-notify
end
