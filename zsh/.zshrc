# SHELL CONFIGURATION
# Zsh reads files in this order: .zshenv -> .zprofile -> .zshrc -> .zlogin


# ZSH VARIABLES
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000


setopt PROMPT_SUBST # Needed for prompt command substitution
setopt AUTO_CD      # Change directory without typing 'cd'
setopt SHARE_HISTORY # Share history between all sessions
bindkey -v
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

[ -f $HOME/.zsh/envvars.zsh ] && source $HOME/.zsh/envvars.zsh
[ -f $HOME/.zsh/prompt.zsh ] && source $HOME/.zsh/prompt.zsh
[ -f $HOME/.zsh/aliases.zsh ] && source $HOME/.zsh/aliases.zsh
[ -f $HOME/.zsh/tmux-integration.zsh ] && source $HOME/.zsh/tmux-integration.zsh
[ -f $HOME/.api-keys/index.sh ] && source $HOME/.api-keys/index.sh
[ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # THIS IS SO SLOW($HOME15ms)
[ -f $HOME/.zsh/fzf-integration.zsh ] && source $HOME/.zsh/fzf-integration.zsh
