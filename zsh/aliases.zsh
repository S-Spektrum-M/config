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
        local editor_cmd_only="${editor_cmd%% *}"
        local editor_name="${editor_cmd_only##*/}"

        local target_window=""
        local win_id win_active pane_cmd
        local editor_is_running=false
        while read -r win_id win_active pane_cmd; do
            if [[ "$pane_cmd" == "$editor_name" ]]; then
                editor_is_running=true
                if [[ "$win_active" == "0" ]]; then
                    target_window="$win_id"
                fi
            fi
        done < <(tmux list-panes -s -F '#{window_id} #{window_active} #{pane_current_command}' 2>/dev/null)

        if [[ -n "$target_window" ]]; then
            tmux select-window -t "$target_window"
            return 0
        fi

        if [[ "$editor_is_running" == "false" ]]; then
            local cur_win
            cur_win=$(tmux display-message -p '#{window_index}' 2>/dev/null)
            if [[ "$cur_win" != "0" ]]; then
                if tmux select-window -t :0 2>/dev/null; then
                    tmux send-keys "${editor_cmd}" C-m
                else
                    tmux new-window -t :0 -c "$PWD" "${editor_cmd}"
                fi
                return 0
            fi
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
alias qc='nvim "/tmp/NVIMcalc_buf.py" && python3 "/tmp/NVIMcalc_buf.py"; command rm /tmp/NVIMcalc_buf.py'

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

rm() {
    # If no arguments, let standard rm handle the help/error
    if [[ $# -eq 0 ]]; then
        command rm
        return
    fi

    # Filter out flags (starting with -) to show only actual files/folders
    local targets=()
    local arg
    for arg in "$@"; do
        [[ "$arg" != -* ]] && targets+=("$arg")
    done

    # If they are just printing help/version flags, skip prompt
    if [[ ${#targets[@]} -eq 0 ]]; then
        command rm "$@"
        return
    fi

    if [[ ${#targets[@]} -gt 50 ]]; then
        print -P "You are about to delete '${#targets[@]} files'"
    else
        # Prompt once with styling
        print -P "%F{yellow}⚠️  You are about to permanently delete:%f"
        for target in "${targets[@]}"; do
            local file_type="file"
            local suffix=""
            if [[ -L "$target" ]]; then
                file_type="symlink"
            elif [[ -d "$target" ]]; then
                file_type="directory"
            elif [[ ! -e "$target" ]]; then
                file_type="not found"
            fi

            if [[ "$file_type" != "not found" ]] && "$GITPATH" rev-parse --is-inside-work-tree &>/dev/null; then
                local git_status
                git_status=$("$GITPATH" status --porcelain "$target" 2>/dev/null)
                if [[ -n "$git_status" ]]; then
                    if echo "$git_status" | grep -qv '^\??'; then
                        suffix=" (uncommitted changes)"
                    else
                        suffix=" (untracked)"
                    fi
                fi
            fi
            print -P "  %F{red}- [${file_type}] ${target}%F{cyan}${suffix}%f"
        done
    fi

    # Read confirmation (1 character input)
    local confirm
    read "confirm?Are you sure? [y/N]: "
    echo "" # New line

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        command rm "$@"
    else
        print -P "%F{green}✓ Operation cancelled. Files are safe.%f"
    fi
}

nvg() {
    rg $@ --vimgrep | nvim
}
