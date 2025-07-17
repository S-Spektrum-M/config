# place this file in ~/.zsh/tmux-integration.zsh

if [[ -n "$TMUX" ]]; then
  export TMUX_PROJ_PATH="$(tmux display-message -p -F "#{pane_current_path}")"
  alias c='cd $TMUX_PROJ_PATH'
fi

if [[ -n "$TMUX" ]]; then
    alias tmat='tmux switch-client -t'
else
    alias tmat='tmux attach -t'
fi
alias tml='tmux list-sessions'


tn() {
    tmux new -A -s "$(basename "$(pwd)")" -c "$(pwd)"
}

# tmux auto attach
if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    if tmux has-session 2>/dev/null; then
      tmux attach || zsh # ensure that a zsh is left behind after detach
    fi
fi
