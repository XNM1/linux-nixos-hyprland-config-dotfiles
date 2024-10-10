function list-op
    echo \n
    lsd -al
    for i in (math (lsd -al | count) + 1)
        echo ""
    end
    commandline -f repaint
end
