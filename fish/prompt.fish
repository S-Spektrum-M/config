# this file should be in ~/.config/fish/prompt.fish

# Disable default vi mode indicator since the prompt arrow changes color per mode
function fish_mode_prompt
end

# Format current directory like zsh's %2c
function __fish_prompt_short_pwd
    set -l tilde_pwd (string replace -r -- '^'(string escape --style=regex -- "$HOME")'(/|$)' '~$1' "$PWD")
    if test "$tilde_pwd" = "/" -o "$tilde_pwd" = "~"
        echo "$tilde_pwd"
        return
    end
    if string match -qr -- '^(/|~/)[^/]+$' "$tilde_pwd"
        echo "$tilde_pwd"
        return
    end
    set -l parts (string split '/' -- "$tilde_pwd")
    string join '/' -- $parts[-2..-1]
end

# Track whether a command was executed since the last prompt render
function __fish_prompt_preexec --on-event fish_preexec
    set -g __fish_cmd_executed 1
end

function fish_prompt
    set -l last_status $status
    set -g __fish_last_status $last_status

    set -l path_color (set_color cyan)
    set -l reset_color (set_color normal)

    # Host color: magenta over SSH, otherwise green on 0 / red on non-zero
    set -l host_color
    if set -q SSH_CONNECTION; and test -n "$SSH_CONNECTION"
        set host_color (set_color magenta)
    else if test $last_status -eq 0
        set host_color (set_color green)
    else
        set host_color (set_color red)
    end

    # Vi mode indicator arrow color
    set -l arrow_color (set_color green) # Insert/Main mode
    switch "$fish_bind_mode"
        case default
            set arrow_color (set_color blue)   # Normal Mode
        case visual
            set arrow_color (set_color yellow) # Visual Mode
        case replace replace_one
            set arrow_color (set_color blue)
    end

    set -l short_host (prompt_hostname)
    set -l short_pwd (__fish_prompt_short_pwd)

    echo -n -s "$host_color" "$short_host:$USER" "$reset_color" ":" "$path_color" "$short_pwd" "$reset_color" " " "$arrow_color" "➜" "$reset_color" " "
end

function fish_right_prompt
    set -l last_status $status
    if set -q __fish_last_status
        set last_status $__fish_last_status
    end

    set -l reset_color (set_color normal)
    set -l blue_color (set_color blue)
    set -l magenta_color (set_color magenta)
    set -l yellow_color (set_color yellow)
    set -l green_color (set_color green)
    set -l red_color (set_color red)
    set -l dim_color (set_color 585858)

    # A. TMUX STATUS
    set -l tmux_part ""
    if set -q TMUX; and test -n "$TMUX"
        set -l tmux_sess (tmux display-message -p '#S' 2>/dev/null)
        if test -n "$tmux_sess"
            set tmux_part "$blue_color$tmux_sess$reset_color "
        end
    end

    # B. EXECUTION TIME (Only if > 2s and a command was just executed)
    set -l exec_time ""
    if set -q __fish_cmd_executed
        set -e __fish_cmd_executed
        if set -q CMD_DURATION; and test "$CMD_DURATION" -gt 2000
            set -l elapsed (printf "%.2fs" (math "$CMD_DURATION / 1000"))
            set exec_time "$magenta_color$elapsed$reset_color "
        end
    end

    # C. GIT STATUS
    set -l git_part ""
    set -l git_bin (set -q GITPATH; and test -n "$GITPATH"; and echo "$GITPATH"; or echo "git")
    if "$git_bin" rev-parse --is-inside-work-tree &>/dev/null
        set -l branch_name ("$git_bin" branch --show-current 2>/dev/null)
        if test -z "$branch_name"
            set branch_name ("$git_bin" symbolic-ref --short HEAD 2>/dev/null)
        end
        if test -n "$branch_name"
            set -l dirty ("$git_bin" status --porcelain 2>/dev/null | head -n 1)
            if test -n "$dirty"
                set git_part "$yellow_color$branch_name $reset_color"
            else
                set git_part "$green_color$branch_name$reset_color "
            end
        end
    end

    # D. EXIT CODE
    set -l exit_code_part ""
    if test $last_status -ne 0
        set exit_code_part "$red_color""[$last_status]$reset_color "
    end

    # E. FINAL ASSEMBLY (240 in 256-color palette = #585858)
    set -l time_str (date "+%H:%M:%S")
    set -l time_part "$dim_color""[$time_str]$reset_color"
    echo -n -s "$exit_code_part" "$exec_time" "$tmux_part" "$git_part" "$time_part"
end
