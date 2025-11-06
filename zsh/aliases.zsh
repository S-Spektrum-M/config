# place this in ~/.zsh/aliases.zsh
alias nv='$EDITOR'
alias md='mkdir'
alias y='yazi'
alias ls='/usr/bin/lsd'
alias la='lsd -a'
alias ll='lsd -l'
alias ltt='lsd --tree'
alias grep="rg"
alias rm='safe-rm'

# C/C++ compiler
alias g++='/usr/bin/g++-14 --std=c++23'
alias clang++='/usr/bin/clang++-20 --std=c++23'
alias clang='/usr/bin/clang-20 --std=c++23'

# Quick Calculator
alias qc='nvim "/tmp/NVIMcalc_buf.py" && python3 "/tmp/NVIMcalc_buf.py"; rm /tmp/NVIMcalc_buf.py'
