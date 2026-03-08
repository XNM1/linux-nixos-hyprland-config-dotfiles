{ pkgs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
  ];
}
