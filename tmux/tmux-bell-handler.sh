#!/bin/bash
SESSION_NAME="$1"
WINDOW_INDEX="$2"
PANE_INDEX="$3"
COMMAND="$4"

CODING_AGENT_CMD="${CODING_AGENT:-agy}"

case "$COMMAND" in
    claude|codex|"$CODING_AGENT_CMD") ;;
    *) exit 0 ;;
esac

echo "${SESSION_NAME}:${WINDOW_INDEX}.${PANE_INDEX}" > /tmp/tmux-last-bell

notify-send -i utilities-terminal "Tmux Bell" "Activity in ${SESSION_NAME}:${WINDOW_INDEX}.${PANE_INDEX} (${COMMAND}) — prefix+b to jump"
