n() {
    local subcommand="$1"
    local note_title="$2"

    if [[ -z "$subcommand" ]]; then
        subcommand=$(printf "view\nadd\n" | fzf)
        if [[ -z "$subcommand" ]]; then
            echo "No subcommand selected."
            return 1
        fi
    fi

    if [[ -z "$note_title" ]]; then
        read "note_title?Note Title: "
    fi

    case "$subcommand" in
        view)
            selected_file=$(fd . $HOME/notes | rg "$note_title" | \
                fzf --preview 'batcat --style=numbers --color=always {}' \
                    --preview-window=right:50%)

            if [[ -z "$selected_file" ]]; then
                echo "No file selected."
                return 1
            fi

            "$EDITOR" "$selected_file"
            ;;
        add)
            if [[ -z "$note_title" ]]; then
                echo "No title specified."
                return 1
            fi
            "$EDITOR" "$HOME/notes/$note_title"
            ;;
        *)
            echo "Unknown subcommand: $subcommand (expected view or add)."
            return 1
            ;;
    esac
}
