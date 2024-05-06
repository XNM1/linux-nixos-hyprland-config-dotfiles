function autostart
    pypr & hyprpaper & waybar & poweralertd & wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store & wl-clip-persist --clipboard regular & avizo-service & systemctl --user start psi-notify & hypridle
end
