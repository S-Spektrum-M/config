#!/usr/bin/bash

# List tmux windows from all sessions, and use fzf for selecting one
SELECTED_WINDOW=$(tmux list-windows -a | fzf)

# If a window was selected, extract the session and window index and switch to it
if [[ -n "$SELECTED_WINDOW" ]]; then
  TARGET_SPEC=$(echo "$SELECTED_WINDOW" | cut -d: -f1-2)
  tmux switch-client -t "$TARGET_SPEC"
fi
