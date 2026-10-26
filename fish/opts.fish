# this file should be in ~/.config/fish/opts.fish

# Suppress default fish greeting
set -g fish_greeting

# Ensure custom completions directory is on fish_complete_path
if not contains -- "$HOME/.config/fish/completions" $fish_complete_path
    set -p fish_complete_path "$HOME/.config/fish/completions"
end

if status is-interactive
    # Set vi keybindings variable so Fish loads it lazily on first prompt
    # instead of running fish_vi_key_bindings twice during startup
    set -g fish_key_bindings fish_vi_key_bindings

    # Share history across concurrent sessions (equivalent to setopt SHARE_HISTORY)
    function __fish_share_history --on-event fish_preexec
        test -z "$fish_private_mode"; and builtin history merge
    end
end
