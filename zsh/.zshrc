# SHELL CONFIGURATION
# Zsh reads files in this order: .zshenv -> .zprofile -> .zshrc -> .zlogin


# Exports and Environment Variables

export EDITOR='/usr/local/bin/nvim'
export VISUAL="$EDITOR"
export MANPAGER='nvim +Man!'
# Tool-specific Exports
export DENO_INSTALL="$HOME/.deno"
export VCPKG_ROOT="$HOME/.vcpkg-bin"
export GOPATH="$HOME/go"
# Library Paths
export LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
# FZF Configuration
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#080a0c,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
# NVM Lazy Loading
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Path Setup
export PATH="\
$HOME/.local/lib/python3.10/site-packages:\
$HOME/.local/bin:\
$DENO_INSTALL/bin:\
$HOME/bin:\
$HOME/.cargo/bin:\
/usr/local/bin:\
/usr/local/cuda/bin:\
/usr/local/cuda-12.4/bin:\
/snap/bin:\
$VCPKG_ROOT:\
$GOPATH/bin:\
$HOME/Projects/catalyst/catalyst-build-system/build:\
$HOME/.nvm/versions/node/v24.2.0/bin:\
$PATH"

# ZSH VARIABLES
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ALIASES
alias nv='$EDITOR'
alias md='mkdir'
alias y='yazi'
alias ls='/usr/bin/lsd'
alias la='lsd -a'
alias ll='lsd -l'
alias ltt='lsd --tree'
alias grep="rg"
if [[ -n "$TMUX" ]]; then
  export TMUX_PROJ_PATH="$(tmux display-message -p -F "#{pane_current_path}")"
  alias c='cd $TMUX_PROJ_PATH'
fi

# C/C++ compiler aliases with modern standards
alias g++='/usr/bin/g++-14 --std=c++23'
alias clang++='/usr/bin/clang++-20 --std=c++23' # Changed from clang to clang++
alias clang='/usr/bin/clang-20 --std=c++23'

# Quick Calculator
alias qc='nvim "$HOME/.tmp/calc_buf.py" && python3 "$HOME/.tmp/calc_buf.py"'

# TMUX aliases
alias tmat='tmux attach -t'
alias tml='tmux list-sessions'
tn() {
    tmux new -A -s "$(basename "$(pwd)")" -c "$(pwd)"
}

# Directory navigation
alias dirs='dirs -p -v'


# FUNCTIONS

# Serve current directory on a given port (defaults to 8000)
serve() {
  local port="${1:-8000}"
  echo "Serving HTTP on port $port..."
  python3 -m http.server "$port"
}

# Extract any archive file
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.Z)         uncompress "$1";;
      *.7z)        7z x "$1"      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


# SHELL BEHAVIOR

# Zsh Options
setopt PROMPT_SUBST # Needed for prompt command substitution
setopt AUTO_CD      # Change directory without typing 'cd'
setopt SHARE_HISTORY # Share history between all sessions
bindkey -v

# Source FZF keybindings and completions if they exist
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# attach to tmux session if one exists
if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    if tmux has-session 2>/dev/null; then
      tmux attach || zsh # ensure that a zsh is left behind after detach
    fi
fi

# Source API keys if the file exists
[ -f ~/.api-keys/index.sh ] && source ~/.api-keys/index.sh


# PROMPT & PLUGINS

# --- Prompt Setup ---
# A clean, two-line prompt can be easier to read
local user_color='%F{green}'
local path_color='%F{cyan}'
local arrow_color='%F{green}'
local reset_color='%f'

PROMPT='${user_color}%m:%n${reset_color}:${path_color}%2c${reset_color} ${arrow_color}➜${reset_color} '

# Load required Zsh module for hooks
autoload -U add-zsh-hook

# Function to set RPROMPT based on Git status
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


zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # THIS IS SO SLOW(~15ms)
