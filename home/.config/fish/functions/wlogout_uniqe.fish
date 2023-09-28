function wlogout_uniqe
    if [ -z $(pidof wlogout) ]
        wlogout
    end
end