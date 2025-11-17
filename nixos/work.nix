{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    slack
    google-cloud-sdk
    awscli2
    ssm-session-manager-plugin
    cargo-lambda
    gnumake
    cmake
    firebase-tools
    redli
    postgresql_18
    pspg
    android-studio
    terragrunt
    terraform
  ];
}
