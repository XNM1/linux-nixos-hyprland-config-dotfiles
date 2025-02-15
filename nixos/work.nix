{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    slack
    aws-sam-cli
    awscli2
    ssm-session-manager-plugin
    cargo-lambda
    gnumake
    cmake
    redli
    firebase-tools
  ];
}
