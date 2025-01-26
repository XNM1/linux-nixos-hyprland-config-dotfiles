function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert

    # Nullify fzf default keybindings
    bind \cT '' -M insert
    bind \cR '' -M insert

    bind \er fzf-history-widget -M insert
    bind \ef fzf-file-preview-widget -M insert
    bind \ec fzf-cd-preview-widget -M insert
    bind \ep fzf-ps-widget -M insert

    bind \e\f clear-op -M insert
    bind \eb back-op -M insert
    bind \eB backtrack-op -M insert
    bind \e/ list-op -M insert

    bind \ea aichat_fish -M insert
end
