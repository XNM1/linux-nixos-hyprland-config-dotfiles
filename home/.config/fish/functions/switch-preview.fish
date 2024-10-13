function switch-preview
    set path "$argv[1]"

    if test -f "$path"
        if test ! -s "$path"
            echo "File is empty"
        else
            archive-preview "$path"
            if string match -q "image/*" (file -b --mime-type "$path")
                image-preview "$path"
            else
                file-preview "$path"
            end
        end
    else if test -d "$path"
        dir-preview "$path"
    else
        echo "Preview unavailable"
    end
end
