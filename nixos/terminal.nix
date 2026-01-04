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
    delta
    mermaid-cli
    posting
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
    aria2
    # wormhole-william
    magic-wormhole-rs
    croc
    # macchina #neofetch alternative in rust
    yt-dlp
    doggo
    sd
    ouch
    duf
    ncdu
    dust
    fd
    jq
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
    jrnl
    python313Packages.faker

    cmatrix
    pipes-rs
    rsclock
    cava
    figlet
    lolcat
    cbonsai
  ];
}
