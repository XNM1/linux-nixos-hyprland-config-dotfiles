{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    (python313.withPackages(ps: with ps; [ pygobject3 gobject-introspection pyqt6-sip]))
    uv
    nodejs
    pnpm
    bun
    lua
    zig
    numbat
    gleam
  ];
}
