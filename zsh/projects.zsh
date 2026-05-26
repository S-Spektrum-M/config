prat() { # project attach
    local proj_dir session_name

    if [[ -n $1 ]]; then
        proj_dir="$HOME/Projects/$1"
    else
        # Using find to avoid ls -F symbols
        if [[ -n $TMUX ]]; then
            proj_dir=$(find "$HOME/Projects" -mindepth 1 -maxdepth 1 -type d | fzf --tmux=90%,90% --preview "lsd --tree --depth 2 --color=always {}")
        else
            proj_dir=$(find "$HOME/Projects" -mindepth 1 -maxdepth 1 -type d | fzf --preview "lsd --tree --depth 2 --color=always {}")
        fi
    fi

    [[ -z "$proj_dir" ]] && return
    session_name=$(basename "$proj_dir")

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -d -s "$session_name" -c "$proj_dir" "$EDITOR"             # Window 0 for code editing
        tmux new-window -t "$session_name:1" -c "$proj_dir" "agy"                   # AI window for code generation and refactoring
        tmux new-window -t "$session_name:2" -c "$proj_dir"                         # zsh window to mess around in
        tmux new-window -t "$session_name:3" -n "git" -c "$proj_dir"                # keep git work in a separate window
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
