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
#   yazi    -> installed via cargo-binstall
printf "\033[90m"
sudo apt-get install -y \
    alacritty tmux fzf git curl wget zsh \
    lsd ripgrep fd-find bat git-delta \
    wl-clipboard libnotify-bin perl \
    gh build-essential
printf "\033[0m"

# ── Rustup installation ──────────────────────────────────────────────────────
CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

if command -v rustup >/dev/null 2>&1 || [ -x "$CARGO_HOME/bin/rustup" ]; then
    echo "Rustup already installed, skipping installation."
else
    echo "Installing Rustup..."
    printf "\033[90m"
    if ! (set -o pipefail; curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y); then
        printf "\033[0m"
        echo "Error: Rustup installation failed. Aborting."
        exit 1
    fi
    printf "\033[0m"
fi

# Make Cargo available to subsequent installers in this script.
if [ -f "$CARGO_HOME/env" ]; then
    . "$CARGO_HOME/env"
fi

# ── Cargo-binstall installation ──────────────────────────────────────────────
if command -v cargo-binstall >/dev/null 2>&1 || [ -x "$CARGO_HOME/bin/cargo-binstall" ]; then
    echo "Cargo-binstall already installed, skipping installation."
else
    echo "Installing cargo-binstall..."
    printf "\033[90m"
    if ! cargo install cargo-binstall --locked; then
        printf "\033[0m"
        echo "Error: Cargo-binstall installation failed. Aborting."
        exit 1
    fi
    printf "\033[0m"
fi

# ── yazi installation ──────────────────────────────────────────────

printf "\033[90m"
cargo binstall yazi-fm --no-confirm --locked
printf "\033[0m"

# ── Clone config repo ────────────────────────────────────────────────────────
GIT_CLONE_LOCATION="${PROJECTS_DIR:-$HOME/Projects}"
CONFIG_DIR="${DOTFILES_DIR:-$GIT_CLONE_LOCATION/config}"

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

# ── Select Neovim config branch ──────────────────────────────────────────────
if ! git -C "$CONFIG_DIR" submodule update --init -- nvim ||
   ! git -C "$CONFIG_DIR/nvim" fetch origin personal ||
   ! git -C "$CONFIG_DIR/nvim" checkout personal ||
   ! git -C "$CONFIG_DIR/nvim" pull --ff-only origin personal; then
    echo "Error: Could not select/update the Neovim personal branch. Aborting."
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
link "$CONFIG_DIR/zsh/.zshenv"             "$HOME/.zshenv"
link "$CONFIG_DIR/zsh/.zshrc"              "$HOME/.zshrc"
link "$CONFIG_DIR/zsh"                     "$HOME/.zsh"
link "$CONFIG_DIR/tmux/.tmux.conf"         "$HOME/.tmux.conf"
link "$CONFIG_DIR/nvim"                    "$HOME/.config/nvim"
link "$CONFIG_DIR/codex/themes/blackbird.tmTheme" "$HOME/.codex/themes/blackbird.tmTheme"
link "$CONFIG_DIR/pi/extensions/mach-dashboard-header.ts" "$HOME/.pi/agent/extensions/mach-dashboard-header.ts"
link "$CONFIG_DIR/pi/extensions/copy-all.ts"              "$HOME/.pi/agent/extensions/copy-all.ts"
link "$CONFIG_DIR/pi/extensions/notify.ts"                "$HOME/.pi/agent/extensions/notify.ts"
link "$CONFIG_DIR/pi/extensions/respond.ts"               "$HOME/.pi/agent/extensions/respond.ts"
link "$CONFIG_DIR/pi/themes/blackbird.json"                "$HOME/.pi/agent/themes/blackbird.json"
link "$CONFIG_DIR/pi/pi.svg"                              "$HOME/.pi/agent/pi.svg"


# ── Link scripts ─────────────────────────────────────────────────────────────
link "$CONFIG_DIR/scripts/project-init"       "$HOME/.local/bin/project-init"
link "$CONFIG_DIR/scripts/disable-bell-notif" "$HOME/.local/bin/disable-bell-notif"
link "$CONFIG_DIR/scripts/enable-bell-notif"  "$HOME/.local/bin/enable-bell-notif"
link "$CONFIG_DIR/scripts/pi-update-daily"    "$HOME/.local/bin/pi-update-daily"

# ── Enable user timers ───────────────────────────────────────────────────────
link "$CONFIG_DIR/systemd/user/pi-update.service" "$HOME/.config/systemd/user/pi-update.service"
link "$CONFIG_DIR/systemd/user/pi-update.timer"   "$HOME/.config/systemd/user/pi-update.timer"

if systemctl --user daemon-reload >/dev/null 2>&1 &&
   systemctl --user enable --now pi-update.timer; then
    echo "  [timer] pi-update.timer enabled"
else
    echo "Warning: Could not enable pi-update.timer with the systemd user manager."
fi

echo "Done."
