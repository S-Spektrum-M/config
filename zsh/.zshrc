# SHELL CONFIGURATION
# Zsh reads files in this order: .zshenv -> .zprofile -> .zshrc -> .zlogin

[ -f $HOME/.zsh/opts.zsh ] && source $HOME/.zsh/opts.zsh
[ -f $HOME/.zsh/envvars.zsh ] && source $HOME/.zsh/envvars.zsh
[ -f $HOME/.zsh/prompt.zsh ] && source $HOME/.zsh/prompt.zsh
[ -f $HOME/.zsh/aliases.zsh ] && source $HOME/.zsh/aliases.zsh
[ -f $HOME/.zsh/tmux-integration.zsh ] && source $HOME/.zsh/tmux-integration.zsh
[ -f $HOME/.api-keys/index.sh ] && source $HOME/.api-keys/index.sh
[ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f $HOME/.zsh/fzf-integration.zsh ] && source $HOME/.zsh/fzf-integration.zsh
