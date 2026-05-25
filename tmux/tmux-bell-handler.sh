#!/bin/bash
SESSION_NAME="$1"
WINDOW_INDEX="$2"
PANE_INDEX="$3"
COMMAND="$4"

case "$COMMAND" in
    claude|agy|codex) ;;
    *) exit 0 ;;
esac

echo "${SESSION_NAME}:${WINDOW_INDEX}.${PANE_INDEX}" > /tmp/tmux-last-bell

notify-send --urgency critical -i utilities-terminal "Tmux Bell" "Activity in ${SESSION_NAME}:${WINDOW_INDEX}.${PANE_INDEX} (${COMMAND}) — prefix+b to jump"
