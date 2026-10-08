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
    jdk17

    dioxus-cli
    # trunk # broken: libdeflate-sys 1.23.1 vs gcc-16 (evex512 target attr removed)
    devenv
    sops
    rops
    git
    git-lfs
    lefthook
    pre-commit-hook-ensure-sops
    lazygit
    lazynpm
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
