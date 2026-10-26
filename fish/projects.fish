function prat # project attach
    set -l projects_dir (set -q PROJECTS_DIR; and test -n "$PROJECTS_DIR"; and echo "$PROJECTS_DIR"; or echo "$HOME/Projects")
    set -l proj_dir
    set -l session_name

    if test -n "$argv[1]"
        set proj_dir "$projects_dir/$argv[1]"
    else
        # Using find to avoid ls -F symbols
        if set -q TMUX; and test -n "$TMUX"
            set proj_dir (find "$projects_dir" -mindepth 1 -maxdepth 1 -type d | fzf --tmux=90%,90% --preview "lsd --tree --depth 2 --color=always {}")
        else
            set proj_dir (find "$projects_dir" -mindepth 1 -maxdepth 1 -type d | fzf --preview "lsd --tree --depth 2 --color=always {}")
        end
    end

    test -z "$proj_dir"; and return
    set session_name (path basename -- "$proj_dir")

    set -l git_bin (set -q GITPATH; and test -n "$GITPATH"; and echo "$GITPATH"; or echo "git")
    set -l coding_agent (set -q CODING_AGENT; and test -n "$CODING_AGENT"; and echo "$CODING_AGENT"; or echo "agy")

    if not tmux has-session -t "$session_name" 2>/dev/null
        tmux new-session -d -s "$session_name" -c "$proj_dir" "$EDITOR"             # Window 0 for code editing
        tmux new-window -d -t "$session_name:1" -c "$proj_dir" "$coding_agent"      # AI window for code generation and refactoring
        tmux new-window -d -t "$session_name:2" -c "$proj_dir"                      # shell window to mess around in
        if "$git_bin" -C "$proj_dir" rev-parse --is-inside-work-tree &>/dev/null
            tmux new-window -d -t "$session_name:3" -n "git" -c "$proj_dir"         # keep git work in a separate window
        end
    end

    # Attachment logic
    if not set -q TMUX; or test -z "$TMUX"
        tmux attach -t "$session_name"
    else
        tmux switch-client -t "$session_name"
    end
end

function prat-widget
    commandline -r "prat"
    commandline -f end-of-line
    commandline -f execute
end
