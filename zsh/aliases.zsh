# place this in ~/.zsh/aliases.zsh
# Open editor, switching to an active instance in another tmux window if available
nv() {
    local args=()
    local new_instance=false
    local arg
    for arg in "$@"; do
        if [[ "$arg" == "-n" ]]; then
            new_instance=true
        else
            args+=("$arg")
        fi
    done

    if [[ -n "$TMUX" && "$new_instance" = false && ${#args[@]} -eq 0 ]]; then
        local editor_cmd="${EDITOR:-nvim}"
        editor_cmd="${editor_cmd%% *}"
        local editor_name="${editor_cmd##*/}"

        local target_window=""
        local win_id win_active pane_cmd
        while read -r win_id win_active pane_cmd; do
            if [[ "$win_active" == "0" && "$pane_cmd" == "$editor_name" ]]; then
                target_window="$win_id"
                break
            fi
        done < <(tmux list-panes -s -F '#{window_id} #{window_active} #{pane_current_command}' 2>/dev/null)

        if [[ -n "$target_window" ]]; then
            tmux select-window -t "$target_window"
            return 0
        fi
    fi

    # Fall back to opening the editor
    local -a cmd
    cmd=(${(z)EDITOR:-nvim})
    "${cmd[@]}" "${args[@]}"
}
alias md='mkdir'
alias y='yazi'
alias ls='/usr/bin/lsd'
alias la='lsd -a'
alias ll='lsd -l'
alias ltt='lsd --tree'

# C/C++ compiler
alias g++='/usr/bin/g++-16 --std=c++23 -freflection'
alias clang++='/usr/bin/clang++-21 --std=c++23'
alias clang='/usr/bin/clang-21 --std=c++23'
alias exp-clang++='$HOME/Projects/llvm-truncated-lambdas/clang/build/bin/clang++  --std=c++26 --target=x86_64-linux-gnu'

# Quick Calculator
alias qc='nvim "/tmp/NVIMcalc_buf.py" && python3 "/tmp/NVIMcalc_buf.py"; rm /tmp/NVIMcalc_buf.py'

# AI
alias cl='claude'
alias ag='${CODING_AGENT:-agy}'
alias cx='codex'

alert() {
  "$@"
  local exit_code=$?
  if [ $exit_code = 0 ]; then
    notify-send --urgency=normal -i terminal "Done" "$*"
  else
    notify-send --urgency=critical -i error "Failed (exit $exit_code)" "$*"
  fi
}
