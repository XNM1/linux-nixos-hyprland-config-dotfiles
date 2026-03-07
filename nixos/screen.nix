{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
