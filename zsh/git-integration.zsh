work() {
    local branch="$1"
    local target_dir
    local abs_target_dir
    local parent_dir
    local session_name
    local current_branch

    if [[ -z "$branch" ]]; then
        echo "Usage: work [branch-name]"
        return 1
    fi

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not inside a git repository."
        return 1
    fi

    parent_dir="$HOME/.tmp/worktrees"
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
    fi

    local randomhash=$(LC_ALL=C tr -dc 'a-f0-9' < /dev/urandom | head -c 8)
    target_dir="$parent_dir/$randomhash"

    abs_target_dir=${target_dir:a}

    if [[ -d "$target_dir" ]]; then
        current_branch=$(git -C "$target_dir" symbolic-ref --short HEAD 2>/dev/null || echo "")

        if [[ "$current_branch" != "$branch" ]]; then
            echo "ERROR: Directory exists but is checked out to '$current_branch' (Expected: '$branch')."
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

        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create worktree."
            return 1
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
