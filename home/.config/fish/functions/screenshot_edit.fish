function screenshot_edit
    swappy -f ~/Pictures/Screenshots/(cd ~/Pictures/Screenshots && ls -tA | head -n1 | awk '{print $NF}')
end
