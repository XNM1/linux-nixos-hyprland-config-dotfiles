function archive-preview
    set archive "$argv[1]"
    set supported_archive_formats tar.gz tar.bz2 tar.xz zip rar 7z

    for format in $supported_archive_formats
        if string match -q "application/$format" (file -b --mime-type "$archive")
            ouch list --tree --no "$archive"
            exit 0
        end
    end
end
