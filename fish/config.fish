# SHELL CONFIGURATION
# Fish reads ~/.config/fish/conf.d/*.fish -> ~/.config/fish/config.fish

function source_if_exists
    test -f "$argv[1]"; and source "$argv[1]"
end

source_if_exists "$HOME/.config/fish/opts.fish"
source_if_exists "$HOME/.config/fish/envvars.fish"
source_if_exists "$HOME/.config/fish/prompt.fish"
source_if_exists "$HOME/.config/fish/aliases.fish"
source_if_exists "$HOME/.config/fish/tmux-integration.fish"
source_if_exists "$HOME/.api-keys/index.sh"
# Note: autosuggestions and syntax highlighting are built into Fish natively
source_if_exists "$HOME/.config/fish/fzf-integration.fish"
source_if_exists "$HOME/.config/fish/git-integration.fish"
source_if_exists "$HOME/.config/fish/projects.fish"
source_if_exists "$HOME/.config/fish/notes.fish"
source_if_exists "$HOME/.config/fish/cpp-helpers.fish"
# source_if_exists "$HOME/.config/fish/banner.fish"

functions -e source_if_exists
