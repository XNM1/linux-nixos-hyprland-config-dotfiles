function fzf-file-preview-widget
    commandline -i (fd --hidden --no-ignore --exclude .git --exclude .direnv | fzf --height 40% --preview-window=right:40% --reverse --preview 'switch-preview {}')
    commandline -f repaint
end
