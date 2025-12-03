# this file should be in ~/.zsh/envvars.zsh

# ZSH VARIABLES
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

export EDITOR='/usr/local/bin/nvim' export VISUAL="$EDITOR"
export MANPAGER='nvim +Man!'
# Tool-specific Exports
export DENO_INSTALL="$HOME/.deno"
export VCPKG_ROOT="$HOME/dev/vcpkg"
export GOPATH="$HOME/go"
# Library Paths
export LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
# NVM Lazy Loading
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

bun() {
  unset -f bun
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
  bun "$@"
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
$HOME/Projects/catalyst/build:\
$HOME/.nvm/versions/node/v24.2.0/bin:\
$BUN_INSTALL/bin:\
$PATH"
export XDG_DATA_DIRS="\
$XDG_DATA_DIRS:\
/var/lib/flatpak/exports/share:\
/home/som/.local/share/flatpak/exports/share"
