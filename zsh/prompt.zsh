# this file should be in ~/.zsh/prompt.zsh
#

# 1. DEFINE COLORS
typeset -g path_color='%F{cyan}'
typeset -g arrow_color='%F{green}' # Default to green (Insert/Main)
typeset -g reset_color='%f'

# 2. SETUP MODULES
autoload -U add-zsh-hook
zmodload zsh/datetime

# 3. DEFINE PROMPT
# %(?.%F{green}.%F{red}) -> IF exit=0 THEN Green ELSE Red
PROMPT='%(?.%F{green}.%F{red})%m:%n${reset_color}:${path_color}%2c${reset_color} ${arrow_color}➜${reset_color} '

# 4. VI MODE INDICATOR
function zle-line-init zle-keymap-select {
    case ${KEYMAP} in
        vicmd)      arrow_color='%F{red}' ;;   # Normal Mode
        viins|main) arrow_color='%F{green}' ;; # Insert Mode
    esac
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# 5. EXECUTION TIMER HOOK
function start_timer() {
  cmd_start_time=$EPOCHREALTIME
}
add-zsh-hook preexec start_timer

# 6. RIGHT PROMPT GENERATOR
function set_rprompt() {
  # A. TMUX STATUS
  local tmux_part=""
  if [ -n "$TMUX" ]; then
    tmux_part="%F{blue}$(tmux display-message -p '#S')%f "
  fi

  # B. EXECUTION TIME (Only if > 2s)
  local exec_time=""
  if [[ -n "$cmd_start_time" ]]; then
    local elapsed=$(($EPOCHREALTIME - $cmd_start_time))
    if (( elapsed > 2 )); then
       printf -v exec_time "%%F{magenta}%.2fs%%f " $elapsed
    fi
    unset cmd_start_time
  fi

  # C. GIT STATUS
  local git_part=""
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch_name
    branch_name=$(git branch --show-current 2>/dev/null)

    if [[ -z "$branch_name" ]]; then
       branch_name=$(git symbolic-ref --short HEAD 2>/dev/null)
    fi

    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
      git_part="%F{yellow}${branch_name} %f"
    else
      git_part="%F{green}${branch_name}%f "
    fi
  fi

  # D. EXIT CODE (New)
  # %(?,,...) -> If exit code is 0 (True), print nothing (empty).
  #              If not 0 (False), print the code [%?] in red.
  local exit_code_part="%(?,,%F{red}[%?]%f )"

  # E. FINAL ASSEMBLY
  RPROMPT="${exit_code_part}${exec_time}${tmux_part}${git_part}%F{240}[%D{%H:%M:%S}]%f"
}

add-zsh-hook precmd set_rprompt
