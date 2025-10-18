{ inputs, pkgs, ... }:

{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.wezterm.packages.${pkgs.system}.default
    kitty
    cool-retro-term

    starship
    helix

    moreutils
    file
    upx
    dotenvx
    git
    lazygit
    delta
    sqlx-cli
    mermaid-cli
    posting
    license-generator
    git-ignore
    gitleaks
    # git-secrets
    pass-git-helper
    jujutsu
    jjui
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
    # taskwarrior3
    asciinema
    asciinema-agg
    aria
    # wormhole-william
    magic-wormhole-rs
    # macchina #neofetch alternative in rust
    dogdns
    sd
    ouch
    duf
    ncdu
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
