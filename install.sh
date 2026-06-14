#!/usr/bin/bash

trap 'printf "\033[0m"' EXIT

# ── Flags ────────────────────────────────────────────────────────────────────
SKIP_UPDATE=false

for arg in "$@"; do
    case "$arg" in
        --skip-update|-s) SKIP_UPDATE=true ;;
        --help|-h)
            echo "Usage: install.sh [--skip-update|-s]"
            echo "  -s, --skip-update   Skip apt update/upgrade (useful on a clean install)"
            exit 0
            ;;
        *)
            echo "Unknown flag: $arg"
            exit 1
            ;;
    esac
done

# ── Sanity checks ────────────────────────────────────────────────────────────
if ! command -v apt >/dev/null 2>&1 || ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: This script currently only supports Ubuntu and derivatives."
    exit 1
fi

echo "Running on: $(lsb_release -ds)"
printf "This script is optimized for the latest Ubuntu release.\n"
printf "As of last update (06/13/2026) this is Ubuntu 26.04\n\n"

# ── Package installation ─────────────────────────────────────────────────────
if [ "$SKIP_UPDATE" = false ]; then
    echo "Updating and upgrading packages..."
    printf "\033[90m"
    sudo apt-get update -y
    sudo apt-get upgrade -y
    printf "\033[0m"
else
    echo "Skipping apt update/upgrade."
fi

echo "Installing packages..."
# Package list covers what the configs actually assume at runtime:
#   terminal/core : alacritty tmux fzf git curl wget zsh
#   shell tooling : lsd ripgrep fd-find bat git-delta (binaries: fdfind, batcat, delta)
#   integrations  : wl-clipboard (wl-copy in tmux), libnotify-bin (notify-send), perl (fzf history widget)
#   dev/project   : gh (project-init), build-essential
# Not installed here (intentionally):
#   neovim  -> installed via the separate mach-nvim installer; EDITOR points at /usr/local/bin/nvim
#   yazi    -> not packaged for Ubuntu; install via cargo or a release binary
printf "\033[90m"
sudo apt-get install -y \
    alacritty tmux fzf git curl wget zsh \
    lsd ripgrep fd-find bat git-delta \
    wl-clipboard libnotify-bin perl \
    gh build-essential
printf "\033[0m"

# ── Clone config repo ────────────────────────────────────────────────────────
GIT_CLONE_LOCATION="$HOME/Projects"
CONFIG_DIR="$GIT_CLONE_LOCATION/config"

mkdir -p "$GIT_CLONE_LOCATION"

if [ -d "$CONFIG_DIR" ]; then
    echo "Config repo already exists at $CONFIG_DIR, pulling latest..."
    printf "\033[90m"
    git -C "$CONFIG_DIR" pull
    printf "\033[0m"
else
    echo "Cloning config repo..."
    printf "\033[90m"
    git clone --recurse-submodules https://github.com/S-Spektrum-M/config "$CONFIG_DIR"
    printf "\033[0m"
fi

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Config repo not found at $CONFIG_DIR after clone. Aborting."
    exit 1
fi

# ── Run nvim install script ────────────────────────────────────────────────────────
if [ -f "$CONFIG_DIR/nvim/install.sh" ]; then
    echo "Running Neovim install script..."
    cd "$CONFIG_DIR/nvim"
    bash install.sh
    cd - > /dev/null
else
    echo "Warning: Neovim install script not found at $CONFIG_DIR/nvim/install.sh"
fi

# ── Symlink helper ───────────────────────────────────────────────────────────
# Usage: link <source> <target>
# Creates the target's parent directory if needed.
# Skips if an identical symlink already exists.
link() {
    local src="$1"
    local tgt="$2"

    mkdir -p "$(dirname "$tgt")"

    if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$src" ]; then
        echo "  [skip] $tgt already linked"
        return
    fi

    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
        echo "  [backup] $tgt -> $tgt.bak"
        mv "$tgt" "$tgt.bak"
    fi

    ln -s "$src" "$tgt"
    echo "  [link] $tgt -> $src"
}

# ── Link configs ─────────────────────────────────────────────────────────────
echo "Linking configs..."
link "$CONFIG_DIR/alacritty"        "$HOME/.config/alacritty"
link "$CONFIG_DIR/git/.gitconfig"         "$HOME/.gitconfig"
link "$CONFIG_DIR/git/.gitconfig.local"   "$HOME/.gitconfig.local"
link "$CONFIG_DIR/zsh/.zshrc"       "$HOME/.zshrc"
link "$CONFIG_DIR/zsh"              "$HOME/.zsh"
link "$CONFIG_DIR/tmux/.tmux.conf"  "$HOME/.tmux.conf"
link "$CONFIG_DIR/nvim"              "$HOME/.config/nvim"

# ── Link scripts ─────────────────────────────────────────────────────────────
link "$CONFIG_DIR/scripts/project-init"       "$HOME/.local/bin/project-init"
link "$CONFIG_DIR/scripts/safe-rm"            "$HOME/.local/bin/safe-rm"
link "$CONFIG_DIR/scripts/disable-bell-notif" "$HOME/.local/bin/disable-bell-notif"
link "$CONFIG_DIR/scripts/enable-bell-notif"  "$HOME/.local/bin/enable-bell-notif"
echo "Done."

