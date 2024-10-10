{ pkgs, ... }:

{
  # Systemd services setup
  systemd.packages = with pkgs; [
    auto-cpufreq
  ];
  
  # Enable Services
  programs.direnv.enable = true;
  services.upower.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;
  services.dbus = {
    enable = true;
    implementation = "broker";
    packages = with pkgs; [
      xfce.xfconf
      gnome2.GConf
    ];
  };
  services.mpd.enable = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.tumbler.enable = true; 
  services.fwupd.enable = true;
  services.auto-cpufreq.enable = true;
  # services.gnome.core-shell.enable = true;
  # services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  environment.systemPackages = with pkgs; [
    at-spi2-atk
    qt6.qtwayland
    psi-notify
    poweralertd
    playerctl
    psmisc
    grim
    slurp
    imagemagick
    swappy
    ffmpeg_6-full
    wl-screenrec
    wl-clipboard
    wl-clip-persist
    cliphist
    xdg-utils
    wtype
    wlrctl
    waybar
    rofi-wayland
    dunst
    avizo
    wlogout
    gifsicle
  ];
}
