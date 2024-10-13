function dir-preview
    set dir "$argv[1]"
    lsd --tree --depth=1 --color=always --icon=always --icon-theme=fancy "$dir"
end
