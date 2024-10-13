{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    file
    upx
    git
    lazygit
    delta
    license-generator
    git-ignore
    gitleaks
    git-secrets
    pass-git-helper
    just
    xh
    process-compose
    # mcfly # terminal history
    zellij
    progress
    noti
    topgrade
    ripgrep
    rewrk
    wrk2
    procs
    tealdeer
    # skim #fzf better alternative in rust
    monolith
    aria
    # macchina #neofetch alternative in rust
    sd
    ouch
    duf
    du-dust
    fd
    jq
    gh
    trash-cli
    zoxide
    tokei
    fzf
    bat
    hexyl
    mdcat
    pandoc
    lsd
    lsof
    gping
    viu
    tre-command
    yazi
    chafa

    cmatrix
    pipes-rs
    rsclock
    cava
    figlet
  ];
}
