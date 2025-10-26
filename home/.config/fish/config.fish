if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias cl="clear"
alias rad="rad-tui"
alias ai="aichat"
alias ai-commit="git diff --staged | ai -r commit-message | hx"
alias ai-emoji-commit="git diff --staged | ai -r emoji-commit-message | hx"
alias ai-branch="git diff --staged | ai -r git-branch | hx"
alias ai-spell="vipe | ai -r improve-writing | hx"
alias ai-email="vipe | ai -r email-answer | hx"
alias ai-linkedin="vipe | ai -r linkedin-answer | hx"
alias aic="ai-commit"
alias aiec="ai-emoji-commit"
alias aib="ai-branch"
alias ais="ai-spell"
alias aie="ai-email"
alias ail="ai-linkedin"
alias lgit="lazygit"
alias ldocker="lazydocker"
alias conf="z ~/.config"
alias nixos="z /etc/nixos"
alias store="z /nix/store"
alias nswitch="sudo nixos-rebuild switch --flake /etc/nixos#isitreal-laptop"
alias nswitchu="sudo nix flake update --flake /etc/nixos; and sudo nixos-rebuild switch --flake /etc/nixos#isitreal-laptop --upgrade"
alias nau="sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos"
alias nsgc="sudo nix-store --gc"
alias ngc="sudo nix-collect-garbage -d"
alias ngc7="sudo nix-collect-garbage --delete-older-than 7d"
alias ngc14="sudo nix-collect-garbage --delete-older-than 14d"

# if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]
#   exec Hyprland
# end

set -gx EDITOR hx
set -gx VOLUME_STEP 5
set -gx BRIGHTNESS_STEP 5

set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/.npm-packages/bin $PATH

set fish_vi_force_cursor
set fish_cursor_default block
set fish_cursor_insert line blink
set fish_cursor_visual underscore blink

set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"

starship init fish | source
zoxide init fish | source
direnv hook fish | source
mise activate fish | source
