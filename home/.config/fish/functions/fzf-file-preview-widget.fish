function fzf-file-preview-widget
    commandline -i (fd --hidden --no-ignore --exclude .git --exclude .direnv | fzf --height 40% --preview-window=right:40% --reverse --preview "test -f {}; and file {} | grep -q text; and bat --color=always --style=numbers --line-range=:500 --wrap=auto {}; or echo 'Preview unavailable for binary files and directories'")
    commandline -f repaint
end
