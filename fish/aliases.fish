# place this in ~/.config/fish/aliases.fish
# Open editor, switching to an active instance in another tmux window if available
function nv
    set -l args
    set -l new_instance false
    for arg in $argv
        if test "$arg" = "-n"
            set new_instance true
        else
            set -a args "$arg"
        end
    end

    set -l editor_cmd (set -q EDITOR; and test -n "$EDITOR"; and echo "$EDITOR"; or echo "nvim")

    if set -q TMUX; and test -n "$TMUX"; and test "$new_instance" = false; and test (count $args) -eq 0
        set -l editor_cmd_parts (string split ' ' -- "$editor_cmd")
        set -l editor_cmd_only "$editor_cmd_parts[1]"
        set -l editor_name (path basename -- "$editor_cmd_only")

        set -l target_window ""
        set -l editor_is_running false
        for line in (tmux list-panes -s -F '#{window_id} #{window_active} #{pane_current_command}' 2>/dev/null)
            set -l fields (string split -m 2 ' ' -- "$line")
            set -l win_id "$fields[1]"
            set -l win_active "$fields[2]"
            set -l pane_cmd "$fields[3]"
            if test "$pane_cmd" = "$editor_name"
                set editor_is_running true
                if test "$win_active" = "0"
                    set target_window "$win_id"
                end
            end
        end

        if test -n "$target_window"
            tmux select-window -t "$target_window"
            return 0
        end

        if test "$editor_is_running" = false
            set -l cur_win (tmux display-message -p '#{window_index}' 2>/dev/null)
            if test "$cur_win" != "0"
                if tmux select-window -t :0 2>/dev/null
                    tmux send-keys "$editor_cmd" C-m
                else
                    tmux new-window -t :0 -c "$PWD" "$editor_cmd"
                end
                return 0
            end
        end
    end

    # Fall back to opening the editor
    set -l cmd (string split ' ' -- "$editor_cmd")
    $cmd $args
end

function md --wraps=mkdir
    mkdir $argv
end

function y --wraps=yazi
    yazi $argv
end

# Browse with yazi, then change to its final directory on exit.
function cy
    set -l tmpfile (mktemp); or return
    yazi $argv --cwd-file="$tmpfile"
    set -l exit_code $status
    if test $exit_code -eq 0
        set -l directory (cat -- "$tmpfile")
        if test -n "$directory" -a "$directory" != "$PWD"
            builtin cd -- "$directory"
            set exit_code $status
        end
    end
    command rm -f -- "$tmpfile"
    return $exit_code
end

function ls --wraps=lsd
    lsd $argv
end

function la --wraps='lsd -a'
    ls -a $argv
end

function ll --wraps='lsd -l'
    ls -l $argv
end

function ltt --wraps='lsd --tree'
    ls --tree $argv
end

# C/C++ compiler
function g++ --wraps=g++-16
    g++-16 --std=c++26 -freflection $argv
end

function clang++ --wraps=clang++-22
    clang++-22 --std=c++26 $argv
end

function clang --wraps=clang-22
    clang-22 --std=c23 $argv
end

# Quick Calculator
function qc
    set -l buf (mktemp --suffix=.py); or return
    nvim "$buf"; and python3 "$buf"
    command rm -f "$buf"
end

# AI
# model/effort/remote-control live in ~/.claude/settings.json; these are per-launch.
function cl --wraps=claude
    claude --permission-mode auto --fallback-model sonnet --ide $argv
end

# One-shot question; session named <dir>-<first-3-words> so it's findable via `cl -r`.
#   clq "what does -fno-semantic-interposition do"
#   git diff | clq "write a commit message"
function clq
    set -l joined "$argv"
    set -l clean (string lower -- "$joined" | string replace -ra '[^[:alnum:] ]' '')
    set -l words (string split -n ' ' -- "$clean")
    set -l slug (string join '-' -- $words[1..3])
    set -l dir_name (path basename -- "$PWD")
    claude -p --model haiku --dangerously-skip-permissions -n "$dir_name-$slug" "$joined"
end

function ag
    set -l agent (set -q CODING_AGENT; and test -n "$CODING_AGENT"; and echo "$CODING_AGENT"; or echo "agy")
    $agent $argv
end

function cx --wraps=codex
    codex $argv
end

function alert
    $argv
    set -l exit_code $status
    if test $exit_code -eq 0
        notify-send --urgency=normal -i terminal "Done" "$argv"
    else
        notify-send --urgency=critical -i error "Failed (exit $exit_code)" "$argv"
    end
end

function rm --wraps=rm
    # If no arguments, let standard rm handle the help/error
    if test (count $argv) -eq 0
        command rm
        return
    end

    # Filter out flags (starting with -) to show only actual files/folders
    set -l targets
    for arg in $argv
        if not string match -q -- '-*' "$arg"
            set -a targets "$arg"
        end
    end

    # If they are just printing help/version flags, skip prompt
    if test (count $targets) -eq 0
        command rm $argv
        return
    end

    set -l git_bin (set -q GITPATH; and test -n "$GITPATH"; and echo "$GITPATH"; or echo "git")

    if test (count $targets) -gt 50
        echo "You are about to delete '"(count $targets)" files'"
    else
        # Prompt once with styling
        echo -s (set_color yellow) "⚠️  You are about to permanently delete:" (set_color normal)
        for target in $targets
            set -l file_type "file"
            set -l suffix ""
            if test -L "$target"
                set file_type "symlink"
            else if test -d "$target"
                set file_type "directory"
            else if not test -e "$target"
                set file_type "not found"
            end

            if test "$file_type" != "not found"; and "$git_bin" rev-parse --is-inside-work-tree &>/dev/null
                set -l git_status ("$git_bin" status --porcelain -- "$target" 2>/dev/null)
                if test -n "$git_status"
                    if printf '%s\n' $git_status | grep -qv '^\??'
                        set suffix " (uncommitted changes)"
                    else
                        set suffix " (untracked)"
                    end
                end
            end
            echo -s "  " (set_color red) "- [$file_type] $target" (set_color cyan) "$suffix" (set_color normal)
        end
    end

    read -l -P "Are you sure? [y/N]: " confirm
    echo ""

    if string match -qr '^[Yy]$' -- "$confirm"
        command rm $argv
    else
        echo -s (set_color green) "✓ Operation cancelled. Files are safe." (set_color normal)
    end
end

function nvg
    rg $argv --vimgrep | nvim
end

function swap
    set -l TMPFILE (mktemp); or return 1
    mv "$argv[1]" "$TMPFILE"; and mv "$argv[2]" "$argv[1]"; and mv "$TMPFILE" "$argv[2]"
end

# Encrypt a file using OpenSSL
function encf
    if test (count $argv) -ne 1
        echo "Usage: encf <filename>" >&2
        return 1
    end

    set -l infile "$argv[1]"
    if not test -f "$infile"
        echo "Error: File '$infile' not found or is not a regular file." >&2
        return 1
    end

    set -l outfile "$infile.cpt"
    if test -e "$outfile"
        read -l -P "Output file '$outfile' already exists. Overwrite? [y/N]: " confirm
        if not string match -qr '^[Yy]$' -- "$confirm"
            echo "Operation cancelled." >&2
            return 1
        end
    end

    set -l tmpfile (mktemp "$outfile.tmp.XXXXXX"); or return 1

    if openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$infile" -out "$tmpfile"
        mv -f "$tmpfile" "$outfile"
        echo "Successfully encrypted '$infile' to '$outfile'"
    else
        command rm -f "$tmpfile"
        echo "Encryption failed." >&2
        return 1
    end
end

# Decrypt a file encrypted with encf
function decf
    if test (count $argv) -ne 1
        echo "Usage: decf <encrypted_file>" >&2
        return 1
    end

    set -l infile "$argv[1]"
    if not test -f "$infile"
        echo "Error: File '$infile' not found or is not a regular file." >&2
        return 1
    end

    set -l outfile
    if string match -q '*.cpt' -- "$infile"
        set outfile (string replace -r '\.cpt$' '' -- "$infile")
    else
        set outfile "$infile.dec"
    end

    if test -e "$outfile"
        read -l -P "Output file '$outfile' already exists. Overwrite? [y/N]: " confirm
        if not string match -qr '^[Yy]$' -- "$confirm"
            echo "Operation cancelled." >&2
            return 1
        end
    end

    set -l tmpfile (mktemp "$outfile.tmp.XXXXXX"); or return 1

    if openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in "$infile" -out "$tmpfile"
        mv -f "$tmpfile" "$outfile"
        echo "Successfully decrypted '$infile' to '$outfile'"
    else
        command rm -f "$tmpfile"
        echo "Decryption failed." >&2
        return 1
    end
end
