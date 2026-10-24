function n
    set -l subcommand "$argv[1]"
    set -l note_title "$argv[2]"

    if test -z "$subcommand"
        set subcommand (printf "view\nadd\n" | fzf)
        if test -z "$subcommand"
            echo "No subcommand selected."
            return 1
        end
    end

    if test -z "$note_title"
        read -l -P "Note Title: " note_title
    end

    set -l editor_cmd (set -q EDITOR; and test -n "$EDITOR"; and string split ' ' -- "$EDITOR"; or echo "nvim")
    set -l fd_bin (command -q fd; and echo "fd"; or echo "fdfind")

    switch "$subcommand"
        case view
            set -l selected_file ($fd_bin . "$HOME/notes" | rg "$note_title" | \
                fzf --preview 'batcat --style=numbers --color=always {}' \
                    --preview-window=right:50%)

            if test -z "$selected_file"
                echo "No file selected."
                return 1
            end

            $editor_cmd "$selected_file"
        case add
            if test -z "$note_title"
                echo "No title specified."
                return 1
            end
            $editor_cmd "$HOME/notes/$note_title"
        case '*'
            echo "Unknown subcommand: $subcommand (expected view or add)."
            return 1
    end
end
