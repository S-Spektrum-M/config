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
	local session_name="${PWD:t}"
	session_name="${session_name//[.:]/_}" # remove dots and colons from session name
	if [[ -n "$TMUX" ]]; then
		tmux has-session -t "=$session_name" 2>/dev/null \
			|| tmux new-session -d -s "$session_name" -c "$PWD"
		tmux switch-client -t "=$session_name"
	else
		tmux new -A -s "$session_name" -c "$PWD"
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

# Pick a directory with yazi, then open its tmux session via newt.
newty() {
    local tmpfile directory exit_code
    tmpfile=$(mktemp) || return
    yazi "$@" --cwd-file="$tmpfile"
    exit_code=$?
    if (( exit_code == 0 )); then
        directory=$(<"$tmpfile")
    fi
    command rm -f -- "$tmpfile"
    (( exit_code == 0 )) || return "$exit_code"
    [[ -n "$directory" ]] || return 0
    newt "$directory"
}
fi

# tmux auto attach
_tmux_socket="${TMUX_TMPDIR:-/tmp}/tmux-$UID/default"
if [[ -z "$TMUX" &&
      -z "$SSH_CONNECTION" &&
      -z "$ALEXANDRIA_LAUNCHED" &&
      -S "$_tmux_socket" ]]; then
    tmux attach 2>/dev/null
fi
unset _tmux_socket
