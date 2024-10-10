{ pkgs, ... }:

{
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    wlsunset
    brightnessctl
  ];
}
