function list-op
    echo \n
    lsd -al
    for i in (lsd -al | count)
        echo ""
    end
    echo ""
    commandline -f repaint
end
