{ pkgs, ...}:

{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.ssh.startAgent = true;

  # FIXME Don't forget to create an authorization mapping file for your user (https://nixos.wiki/wiki/Yubikey#pam_u2f)
  security.pam.u2f = {
    enable = true;
    settings.cue = true;
    control = "sufficient";
  };

  security.pam.services = {
    greetd.u2fAuth = true;
    sudo-rs.u2fAuth = true;
    hyprlock.u2fAuth = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
  ];
}
