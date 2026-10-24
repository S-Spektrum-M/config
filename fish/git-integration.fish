function work
    set -l branch "$argv[1]"

    if test -z "$branch"
        echo "Usage: work [branch-name]"
        return 1
    end

    set -l git_bin (set -q GITPATH; and test -n "$GITPATH"; and echo "$GITPATH"; or echo "git")

    if not "$git_bin" rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: Not inside a git repository."
        return 1
    end

    set -l parent_dir "$HOME/.tmp/worktrees"
    if not test -d "$parent_dir"
        mkdir -p "$parent_dir"
    end

    set -l randomhash (LC_ALL=C tr -dc 'a-f0-9' < /dev/urandom | head -c 8)
    set -l target_dir "$parent_dir/$randomhash"
    set -l abs_target_dir (path resolve -- "$target_dir")

    if test -d "$target_dir"
        set -l current_branch ("$git_bin" -C "$target_dir" symbolic-ref --short HEAD 2>/dev/null; or echo "")

        if test "$current_branch" != "$branch"
            echo "ERROR: Directory exists but is checked out to '$current_branch' (Expected: '$branch')."
            return 1
        end
    else
        echo "Creating worktree for '$branch' at '$target_dir'..."

        if "$git_bin" show-ref --verify --quiet "refs/heads/$branch"; or "$git_bin" show-ref --verify --quiet "refs/remotes/origin/$branch"
            "$git_bin" worktree add "$target_dir" "$branch"
        else
            "$git_bin" worktree add -b "$branch" "$target_dir"
        end

        if test $status -ne 0
            echo "Error: Failed to create worktree."
            return 1
        end
    end

    set -l session_name (string replace -ra '[/.]' '-' -- "$branch")

    if tmux has-session -t "$session_name" 2>/dev/null
        echo "Session '$session_name' exists."
    else
        echo "Creating new Tmux session '$session_name'..."
        tmux new-session -d -s "$session_name" -c "$abs_target_dir"
    end

    if set -q TMUX; and test -n "$TMUX"
        echo "Switching to session '$session_name'..."
        tmux switch-client -t "$session_name"
    else
        echo "Attaching to session '$session_name'..."
        tmux attach-session -t "$session_name"
    end
end
