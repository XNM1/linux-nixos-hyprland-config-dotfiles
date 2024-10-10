{ pkgs, ... }:

{
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  environment.systemPackages = with pkgs; [
    overskride
  ];
}
