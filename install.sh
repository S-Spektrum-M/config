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
printf "As of last update (12/09/2025) this is Ubuntu 25.10\n\n"

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
printf "\033[90m"
sudo apt-get install -y alacritty tmux fzf git curl wget
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
    git clone https://github.com/S-Spektrum-M/config "$CONFIG_DIR"
    printf "\033[0m"
fi

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Config repo not found at $CONFIG_DIR after clone. Aborting."
    exit 1
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
link "$CONFIG_DIR/git/.gitconfig"   "$HOME/.gitconfig"
link "$CONFIG_DIR/zsh/.zshrc"       "$HOME/.zshrc"
link "$CONFIG_DIR/zsh"              "$HOME/.zsh"
link "$CONFIG_DIR/tmux/.tmux.conf"  "$HOME/.tmux.conf"
echo "Done."
