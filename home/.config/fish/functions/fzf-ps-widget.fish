function fzf-ps-widget
    commandline -i (pgrep -a . | fzf --height 40%)
    commandline -f repaint
end
