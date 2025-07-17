# this file should be in ~/.zsh/prompt.zsh
#
local user_color='%F{green}'
local path_color='%F{cyan}'
local arrow_color='%F{green}'
local reset_color='%f'

# PROMPT: username:hostname:"2 last dirs" ➜
PROMPT='${user_color}%m:%n${reset_color}:${path_color}%2c${reset_color} ${arrow_color}➜${reset_color} '

# Load required Zsh module for hooks
autoload -U add-zsh-hook

# RPROMPT: tmux-session name(if attached) git branch/modifications(if in git dir) time
function set_rprompt() {
  local tmux_part=""
  if [ -n "$TMUX" ]; then
    tmux_part="%F{blue}$(tmux display-message -p '#S')%f "
  fi

  # Check if inside a Git repository
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch_name
    branch_name=$(git rev-parse --abbrev-ref HEAD)

    # Check for any staged or unstaged changes
    if [[ -n "$(git status --porcelain)" ]]; then
      # If modifications exist, show branch in yellow with an asterisk
      RPROMPT="${tmux_part}%F{yellow}${branch_name}* %f%F{240}[%D{%H:%M:%S}]%f"
    else
      # If clean, show branch in green
      RPROMPT="${tmux_part}%F{green}${branch_name}%f %F{240}[%D{%H:%M:%S}]%f"
    fi
  else
    # If not in a Git repo, just show the time
    RPROMPT="${tmux_part}%F{240}[%D{%H:%M:%S}]%f"
  fi
}

# Add the function to the precmd hook
add-zsh-hook precmd set_rprompt
