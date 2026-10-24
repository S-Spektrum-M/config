# this file should be in ~/.config/fish/opts.fish

# Suppress default fish greeting
set -g fish_greeting

# Ensure custom completions directory is on fish_complete_path
if not contains -- "$HOME/.config/fish/completions" $fish_complete_path
    set -p fish_complete_path "$HOME/.config/fish/completions"
end

if status is-interactive
    # Vi keybindings (equivalent to bindkey -v)
    fish_vi_key_bindings

    # Share history across concurrent sessions (equivalent to setopt SHARE_HISTORY)
    function __fish_share_history --on-event fish_preexec
        test -z "$fish_private_mode"; and builtin history merge
    end
end
