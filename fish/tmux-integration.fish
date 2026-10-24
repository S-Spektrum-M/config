# place this file in ~/.config/fish/tmux-integration.fish

if set -q TMUX; and test -n "$TMUX"
    set -gx TMUX_PROJ_PATH "$PWD"
    function c
        cd "$TMUX_PROJ_PATH"
    end
    alias tmat='tmux switch-client -t'
else
    alias tmat='tmux attach -t'
end
alias tml='tmux list-sessions'

function ssh --wraps=ssh
    if set -q TMUX; and test -n "$TMUX"
        # Store the SSH command/target in a tmux window option.
        tmux set-window-option @remote_ssh "$argv"
        command ssh $argv
        set -l exit_code $status
        # Clear it when the session ends.
        tmux set-window-option -u @remote_ssh
        return $exit_code
    else
        command ssh $argv
    end
end

function tn
    set -l session_name (path basename -- "$PWD")
    set session_name (string replace -ra '[.:]' '_' -- "$session_name") # remove dots and colons from session name
    if set -q TMUX; and test -n "$TMUX"
        tmux has-session -t "=$session_name" 2>/dev/null
        or tmux new-session -d -s "$session_name" -c "$PWD"
        tmux switch-client -t "=$session_name"
    else
        tmux new -A -s "$session_name" -c "$PWD"
    end
end

if set -q TMUX; and test -n "$TMUX"
    function newt
        if test -z "$argv[1]"
            echo "Usage: newt <path>"
            return 1
        end
        set -l orig_dir (pwd)
        cd "$argv[1]"; and tn
        set -l exit_code $status
        cd "$orig_dir"
        return $exit_code
    end

    # Pick a directory with yazi, then open its tmux session via newt.
    function newty
        set -l tmpfile (mktemp); or return
        yazi $argv --cwd-file="$tmpfile"
        set -l exit_code $status
        set -l directory ""
        if test $exit_code -eq 0
            set directory (cat -- "$tmpfile")
        end
        command rm -f -- "$tmpfile"
        test $exit_code -eq 0; or return $exit_code
        test -n "$directory"; or return 0
        newt "$directory"
    end
end

# tmux auto attach
set -l _tmux_tmpdir (set -q TMUX_TMPDIR; and test -n "$TMUX_TMPDIR"; and echo "$TMUX_TMPDIR"; or echo "/tmp")
set -l _tmux_socket "$_tmux_tmpdir/tmux-"(id -u)"/default"
if status is-interactive
    and not set -q TMUX
    and not set -q SSH_CONNECTION
    and not set -q ALEXANDRIA_LAUNCHED
    and test -S "$_tmux_socket"
    tmux attach 2>/dev/null
end
