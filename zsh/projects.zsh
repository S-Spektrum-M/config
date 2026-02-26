prat() { # project attach
    local proj_dir session_name

    if [[ -n $1 ]]; then
        proj_dir="$HOME/Projects/$1"
    else
        # Using find to avoid ls -F symbols
        if [[ -n $TMUX ]]; then
            proj_dir=$(find "$HOME/Projects" -mindepth 1 -maxdepth 1 -type d | fzf --tmux)
        else
            proj_dir=$(find "$HOME/Projects" -mindepth 1 -maxdepth 1 -type d | fzf)
        fi
    fi

    [[ -z "$proj_dir" ]] && return
    session_name=$(basename "$proj_dir")

    if [[ -n "$proj" ]]; then
        local session_name="$(basename "$proj")"
        if [[ -z $TMUX ]]; then
            tmux new -A -s "$session_name" -c "$HOME/Projects/$proj"
        else
            tmux new-session -d -s "$session_name" -c "$HOME/Projects/$proj" 2>/dev/null
            tmux switch-client -t "$session_name"
        fi
    fi

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -d -s "$session_name" -c "$proj_dir" "$EDITOR"
        tmux new-window -t "$session_name:1" -c "$proj_dir" "gemini"
    fi

    # Attachment logic
    if [[ -z $TMUX ]]; then
        tmux attach -t "$session_name"
    else
        tmux switch-client -t "$session_name"
    fi
}


prat-widget() {
    BUFFER="prat"
    zle end-of-line
    zle accept-line
}

zle -N prat-widget
bindkey '^P' prat-widget
