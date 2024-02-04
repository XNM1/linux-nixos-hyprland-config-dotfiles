{ pkgs, ...}:

{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  # FIXME Replace [your_yubikey_model_id] with the actual model ID of your YubiKey. You can find the model ID using the `lsusb` command, typically available as a part of the `usbutils` package
  services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="your_yubikey_model_id",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  environment.systemPackages = with pkgs; [
    pam_u2f
  ];
}
