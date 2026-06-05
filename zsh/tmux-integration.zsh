# place this file in ~/.zsh/tmux-integration.zsh

if [[ -n "$TMUX" ]]; then
    export TMUX_PROJ_PATH="$(tmux display-message -p -F "#{pane_current_path}")"
    alias c='cd $TMUX_PROJ_PATH'
    alias tmat='tmux switch-client -t'
else
    alias tmat='tmux attach -t'
fi
alias tml='tmux list-sessions'

tn() {
    local session_name="$(basename "$(pwd)")"
    if [[ -n "$TMUX" ]]; then
        tmux has-session -t "$session_name" 2>/dev/null || tmux new-session -d -s "$session_name" -c "$(pwd)"
        tmux switch-client -t "$session_name"
    else
        tmux new -A -s "$session_name" -c "$(pwd)"
    fi
}

if [[ -n "$TMUX" ]]; then
newt() {
    if [[ -z "$1" ]]; then
        echo "Usage: newt <path>"
        return 1
    fi
    local orig_dir="$(pwd)"
    cd "$1" && tn
    local exit_code=$?
    cd "$orig_dir"
    return $exit_code
}
fi

# tmux auto attach
if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    if tmux has-session 2>/dev/null; then
        tmux attach || zsh # ensure that a zsh is left behind after detach
    fi
fi
