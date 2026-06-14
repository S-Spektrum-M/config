# this file should be in ~/.zsh/envvars.zsh

# ZSH VARIABLES
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

export EDITOR='/usr/local/bin/nvim'
export VISUAL="$EDITOR"
export GITPATH='/usr/bin/git'
export MANPAGER='nvim +Man!'
# Tool-specific Exports
export MAKEFLAGS="-j$(nproc)"
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

# Resolve the active node bin dir without loading nvm.
# Prefer `nvm alias default`; fall back to the highest installed version.
NODE_BIN=""
if [[ -r "$NVM_DIR/alias/default" ]]; then
    # nvm stores the alias without a leading 'v' (e.g. "24.2.0") but dirs have it ("v24.2.0")
    _node_default="$(<"$NVM_DIR/alias/default")"
    for _cand in "$_node_default" "v${_node_default#v}"; do
        [[ -d "$NVM_DIR/versions/node/$_cand/bin" ]] && { NODE_BIN="$NVM_DIR/versions/node/$_cand/bin"; break; }
    done
fi
if [[ -z "$NODE_BIN" ]]; then
    # (Nn) = nullglob + numeric/version sort; [-1] is the newest
    _node_dirs=($NVM_DIR/versions/node/*/bin(Nn))
    (( ${#_node_dirs} )) && NODE_BIN="${_node_dirs[-1]}"
fi
unset _node_default _node_dirs _cand

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
$HOME/Projects/catalyst/catalyst/build/common-ccache-release:\
$HOME/Projects/catalyst/cob/build/common-ccache-release:\
$HOME/Projects/catalyst/crab/build/common-ccache-release:\
$HOME/Projects/agents-md-generator/:\
${NODE_BIN:+$NODE_BIN:}\
$BUN_INSTALL/bin:\
$HOME/.lmstudio/bin:\
$PATH"
export XDG_DATA_DIRS="\
$XDG_DATA_DIRS:\
/var/lib/flatpak/exports/share:\
$HOME/.local/share/flatpak/exports/share"
