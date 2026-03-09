function wlogout_uniqe
    if not pidof wlogout >/dev/null
        wlogout
    end
end
