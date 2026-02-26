function cds() {
  builtin cd "$@" || return $?
  local script_path=".scripts/index.zsh"
  if [[ -f "$script_path" ]]; then
    echo ">> Sourcing $script_path"
    source "$script_path"
  fi
}

alias cd=cds
