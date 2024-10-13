function image-preview
    set image "$argv[1]"

    # Retrieve the current terminal dimensions and reduce them slightly to avoid boundary issues
    set term_width (math (tput cols) - 1)
    set term_height (math (tput lines) - 1)

    chafa "$image" --size="$term_width"x"$term_height"
end
