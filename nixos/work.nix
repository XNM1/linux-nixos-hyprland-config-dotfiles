{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    slack
    aws-sam-cli
    awscli2
    cargo-lambda
    gnumake
    cmake
    firebase-tools
  ];
}
