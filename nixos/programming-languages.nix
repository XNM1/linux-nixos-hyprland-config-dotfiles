{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    (python313Full.withPackages(ps: with ps; [ pygobject3 gobject-introspection pyqt6-sip]))
    uv
    nodePackages_latest.nodejs
    nodePackages_latest.pnpm
    bun
    lua
    zig
    numbat
  ];
}
