{ pkgs, ... }:

{
  # Disable conflicting services
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = false; # Gnome/KDE default, conflicts with TLP

  # Enable Services
  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # --- Power/Performance Strategy ---

      # ON AC: Max performance
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      # ON BATTERY: Conservative for lifespan
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # --- Battery Health (Longevity) ---
      # This is critical for "Always on AC" usage on Lenovo.
      STOP_CHARGE_THRESH_BAT0 = 1; # battery conservation mode

      # --- Boost control ---
      # Allow turbo boost on AC, disable on Battery
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # GPU POWER MANAGEMENT (RTX 4050/60)
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # PCI
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersave";
    };
  };

  services.upower.enable = true;
  programs.dconf.enable = true;
  services.dbus = {
    enable = true;
    implementation = "broker";
    packages = with pkgs; [
      xfconf
      gnome2.GConf
    ];
  };
  services.mpd.enable = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.tumbler.enable = true; 
  services.fwupd.enable = true;
  # services.gnome.core-shell.enable = true;
  # services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  environment.systemPackages = with pkgs; [
    qutebrowser
    zathura
    mpv
    mpv-handler
    imv
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
    rofi
    dunst
    avizo
    wlogout
    gifsicle
  ];
}
