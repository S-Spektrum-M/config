# SHELL CONFIGURATION
# Zsh reads files in this order: .zshenv -> .zprofile -> .zshrc -> .zlogin

source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

source_if_exists "$HOME/.zsh/opts.zsh"
source_if_exists "$HOME/.zsh/envvars.zsh"
source_if_exists "$HOME/.zsh/prompt.zsh"
source_if_exists "$HOME/.zsh/aliases.zsh"
source_if_exists "$HOME/.zsh/tmux-integration.zsh"
source_if_exists "$HOME/.api-keys/index.sh"
source_if_exists "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_if_exists "$HOME/.zsh/fzf-integration.zsh"
source_if_exists "$HOME/.zsh/git-integration.zsh"
source_if_exists "$HOME/.zsh/projects.zsh"
source_if_exists "$HOME/.zsh/notes.zsh"
source_if_exists "$HOME/.zsh/cpp-helpers.zsh"
source_if_exists "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# source_if_exists "$HOME/.zsh/banner.zsh"

unset -f source_if_exists
