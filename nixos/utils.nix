{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mold
    gcc13
    jdk11
  ];
}
