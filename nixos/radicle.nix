{ inputs, pkgs, ... }:

{
  services.radicle = {
    enable = false;
    checkConfig = false;
  };

  environment.systemPackages = with pkgs; [
    inputs.radicle-tui.packages.${pkgs.system}.default
    radicle-node
  ];
}
