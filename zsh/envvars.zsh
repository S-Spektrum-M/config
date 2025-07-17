# this file should be in ~/.zsh/envvars.zsh

# ZSH VARIABLES
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

export EDITOR='/usr/local/bin/nvim' export VISUAL="$EDITOR"
export MANPAGER='nvim +Man!'
# Tool-specific Exports
export DENO_INSTALL="$HOME/.deno"
export VCPKG_ROOT="$HOME/.vcpkg-bin"
export GOPATH="$HOME/go"
# Library Paths
export LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
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
