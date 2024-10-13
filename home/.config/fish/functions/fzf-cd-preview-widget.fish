function fzf-cd-preview-widget
    set selected_dir (fd --type d --hidden --no-ignore --exclude .git --exclude .direnv | fzf --height 40% --reverse --preview 'dir-preview {}' --preview-window=right:40%)

    if test -n "$selected_dir"
        cd "$selected_dir"
    end
    commandline -f repaint
end
