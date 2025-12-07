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
    diffnav
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
    hurl
    grex

    surrealdb
    surrealdb-migrations
    surrealist
  ];
}
