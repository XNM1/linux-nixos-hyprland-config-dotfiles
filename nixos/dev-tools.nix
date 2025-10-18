{ pkgs, ... }:

{
  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    mold
    gcc
    clang
    lld
    lldb
    musl
    jdk11

    dioxus-cli
    trunk
    devenv

    surrealdb
    surrealdb-migrations
    surrealist
  ];
}
