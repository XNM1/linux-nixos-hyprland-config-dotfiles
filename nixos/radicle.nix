{ pkgs, ... }:

{
  services.radicle = {
    enable = false;
    checkConfig = false;
  };

  environment.systemPackages = with pkgs; [
    radicle-tui
    radicle-job
    radicle-native-ci
    radicle-ci-broker
    radicle-node
  ];
}
