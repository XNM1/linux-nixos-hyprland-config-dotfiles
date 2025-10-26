{ pkgs, lib, ... }:

{
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable Security Services
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };
  security.sudo.enable = false;
  users.users.root.hashedPassword = "!";
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
    packages = with pkgs; [
      apparmor-utils
      apparmor-profiles
    ];
  };

  security.pam.services = {
    login.enableAppArmor = true;
    sshd.enableAppArmor = true;
    sudo-rs.enableAppArmor = true;
    su.enableAppArmor = true;
    greetd.enableAppArmor = true;
    u2f.enableAppArmor = true;
  };

  services.dbus.apparmor = "enabled";
  services.fail2ban.enable = true;
  # security.polkit.enable = true;
  programs.browserpass.enable = true;
  services.clamav = {
    daemon.enable = true;
    fangfrisch.enable = true;
    fangfrisch.interval = "daily";
    updater.enable = true;
    updater.interval = "daily"; #man systemd.time
    updater.frequency = 12;
  };
  programs.firejail = {
    enable = true;
    wrappedBinaries = { 
      mpv = {
        executable = "${lib.getBin pkgs.mpv}/bin/mpv";
        profile = "${pkgs.firejail}/etc/firejail/mpv.profile";
      };
      imv = {
        executable = "${lib.getBin pkgs.imv}/bin/imv";
        profile = "${pkgs.firejail}/etc/firejail/imv.profile";
      };
      zathura = {
        executable = "${lib.getBin pkgs.zathura}/bin/zathura";
        profile = "${pkgs.firejail}/etc/firejail/zathura.profile";
      };
      discord = {
        executable = "${lib.getBin pkgs.discord}/bin/discord";
        profile = "${pkgs.firejail}/etc/firejail/discord.profile";
      };
      slack = {
        executable = "${lib.getBin pkgs.slack}/bin/slack";
        profile = "${pkgs.firejail}/etc/firejail/slack.profile";
      };
      Telegram = {
        executable = "${lib.getBin pkgs.tdesktop}/bin/Telegram";
        profile = "${pkgs.firejail}/etc/firejail/Telegram.profile";
      };
      brave = {
        executable = "${lib.getBin pkgs.brave}/bin/brave";
        profile = "${pkgs.firejail}/etc/firejail/brave.profile";
      };
      qutebrowser = {
        executable = "${lib.getBin pkgs.qutebrowser}/bin/qutebrowser";
        profile = "${pkgs.firejail}/etc/firejail/qutebrowser.profile";
      };
      thunar = {
        executable = "${lib.getBin pkgs.xfce.thunar}/bin/thunar";
        profile = "${pkgs.firejail}/etc/firejail/thunar.profile";
      };
      vscodium = {
        executable = "${lib.getBin pkgs.vscodium}/bin/vscodium";
        profile = "${pkgs.firejail}/etc/firejail/vscodium.profile";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    gnupg
    openssl

    vulnix       #scan command: vulnix --system
    clamav       #scan command: sudo freshclam; clamscan [options] [file/directory/-]

    # passphrase2pgp
    pass-wayland
    pass2csv
    passExtensions.pass-tomb
    passExtensions.pass-update
    passExtensions.pass-otp
    passExtensions.pass-import
    passExtensions.pass-audit
    tomb
    pwgen
    pwgen-secure
  ];
}
