# If you come from bash you might have to change your $PATH.
export DENO_INSTALL="$HOME/.deno"
export VCPKG_ROOT="$HOME/.vcpkg-bin"
export GOPATH=$HOME/go
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
$GOROOT/bin:\
$GOPATH/bin:\
$HOME/Projects/catalyst/catalyst-build-system/build/:\
$PATH"
export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64
export MANPAGER='nvim +Man!'


# Path to your oh-my-zsh installation.

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
plugins=(
    git
    zsh-vi-mode
)

export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)
# source /usr/share/fzf/key-bindings.zsh
# source /usr/share/fzf/completion.zsh

export EDITOR=/usr/local/bin/nvim
export VISUAL="$EDITOR"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias nv=$EDITOR
alias md="mkdir"
alias tmat="tmux attach -t"
alias spt="zsh $HOME/projects/dotfiles/scripts/launchspt.sh 2>/dev/null"
alias open-docs="zsh $HOME/projects/dotfiles/scripts/open-docs.sh 2>/dev/null"
alias g++="/usr/bin/g++-14 --std=c++23"
alias clang="/usr/bin/clang-20 --std=c++23"
alias dirs="dirs -p -v"
alias y="yazi"
alias c="clear"
alias ls="/usr/bin/lsd"
alias qc="$EDITOR $HOME/.tmp/calc_buf.py && python3 $HOME/.tmp/calc_buf.py"
# eval "$(zoxide init zsh)"

export EDITOR=$HOME/squashfs-root/usr/bin/nvim

# API KEYS
source ~/.api-keys/index.sh

cppman-fzf() {
  local query
  query=$(cat ~/.cache/cppman/new_symbols.txt | fzf --prompt="C++ Symbol> ")
  [[ -n "$query" ]] && cppman "$query"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
    if tmux has-session 2>/dev/null; then
      tmux attach || zsh
    fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
