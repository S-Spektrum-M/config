# place this in ~/.zsh/aliases.zsh
alias nv='$EDITOR'
alias md='mkdir'
alias y='yazi'
alias ls='/usr/bin/lsd'
alias la='lsd -a'
alias ll='lsd -l'
alias ltt='lsd --tree'

# C/C++ compiler
alias g++='/usr/bin/g++-15 --std=c++23'
alias clang++='/usr/bin/clang++-21 --std=c++23'
alias clang='/usr/bin/clang-21 --std=c++23'

# Quick Calculator
alias qc='nvim "/tmp/NVIMcalc_buf.py" && python3 "/tmp/NVIMcalc_buf.py"; rm /tmp/NVIMcalc_buf.py'

alert() {
  "$@"
  local exit_code=$?
  if [ $exit_code = 0 ]; then
    notify-send --urgency=normal -i terminal "Done" "$*"
  else
    notify-send --urgency=critical -i error "Failed (exit $exit_code)" "$*"
  fi
}
