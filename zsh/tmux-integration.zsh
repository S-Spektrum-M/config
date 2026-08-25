# place this file in ~/.zsh/tmux-integration.zsh

if [[ -n "$TMUX" ]]; then
    export TMUX_PROJ_PATH="$PWD"
    alias c='cd $TMUX_PROJ_PATH'
    alias tmat='tmux switch-client -t'
else
    alias tmat='tmux attach -t'
fi
alias tml='tmux list-sessions'

ssh() {
    if [ -n "$TMUX" ]; then
        # Store the SSH command/target in a tmux window option.
        tmux set-window-option @remote_ssh "$*"
        command ssh "$@"
        # Clear it when the session ends.
        tmux set-window-option -u @remote_ssh
    else
        command ssh "$@"
    fi
}

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
_tmux_socket="${TMUX_TMPDIR:-/tmp}/tmux-$UID/default"
if [[ -z "$TMUX" &&
      -z "$SSH_CONNECTION" &&
      -S "$_tmux_socket" ]]; then
    tmux attach 2>/dev/null
fi
unset _tmux_socket
