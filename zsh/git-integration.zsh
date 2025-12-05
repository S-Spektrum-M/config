wt() {
    local branch="$1"
    local dir_arg="$2"
    local target_dir
    local abs_target_dir
    local parent_dir
    local session_name
    local current_branch

    if [[ -z "$branch" ]]; then
        echo "Usage: wt [branch-name] [directory (optional)]"
        return 1
    fi

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not inside a git repository."
        return 1
    fi

    if [[ -z "$dir_arg" ]]; then
        # Default to ../branch-name
        target_dir="$(git rev-parse --show-toplevel 2>/dev/null)/../$branch"
    else
        target_dir="$dir_arg"
    fi

    parent_dir=${target_dir:h}
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
    fi

    abs_target_dir=${target_dir:a}

    if [[ -d "$target_dir" ]]; then
        echo "Directory '$target_dir' exists. Verifying branch..."

        current_branch=$(git -C "$target_dir" symbolic-ref --short HEAD 2>/dev/null || echo "")

        if [[ "$current_branch" == "$branch" ]]; then
            echo "Match confirmed. Attaching to session..."
        else
            echo "WARNING: Directory exists but is checked out to '$current_branch' (Expected: '$branch')."
            echo "Aborting."
            return 1
        fi

    else
        echo "Creating worktree for '$branch' at '$target_dir'..."

        if git show-ref --verify --quiet "refs/heads/$branch" || \
           git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            git worktree add "$target_dir" "$branch"
        else
            git worktree add -b "$branch" "$target_dir"
        fi
    fi

    session_name=${branch//[\/.]/-}

    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Session '$session_name' exists."
    else
        echo "Creating new Tmux session '$session_name'..."
        tmux new-session -d -s "$session_name" -c "$abs_target_dir"
    fi

    if [[ -n "$TMUX" ]]; then
        echo "Switching to session '$session_name'..."
        tmux switch-client -t "$session_name"
    else
        echo "Attaching to session '$session_name'..."
        tmux attach-session -t "$session_name"
    fi
}
