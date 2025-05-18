{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    slack
    aws-sam-cli
    google-cloud-sdk
    awscli2
    ssm-session-manager-plugin
    cargo-lambda
    gnumake
    cmake
    firebase-tools
    redli
    android-studio
  ];
}
