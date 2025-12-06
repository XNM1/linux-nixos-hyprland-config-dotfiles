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
    dotenvx
    git
    lazygit
    sqlx-cli
    license-generator
    git-ignore
    gitleaks
    pass-git-helper
    jujutsu
    jjui
    just
    mise
    gh
    gh-dash
    diffnav
    hurl
    grex

    surrealdb
    surrealdb-migrations
    surrealist
  ];
}
