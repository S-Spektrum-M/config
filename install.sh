#!/usr/bin/bash
#

trap 'printf "\033[0m"' EXIT


printf "This script is optimized for the Latest Ubuntu Release\nAs of last update (12/09/2025) this is Ubuntu 25.10"

if ! command -v apt >/dev/null 2>&1 || ! command -v apt-get > /dev/null 2>&1; then
    echo "Error: This script currently only supports Ubuntu and derivatives (and may work on Debian)."
    return 1
fi

echo "Running on: $(lsb_release  -ds)"

# Install Packages
echo "Upgrading Packges"
printf "\033[90m"
sudo apt-get update
printf "\033[0m"
printf "\033[90m"
sudo apt-get upgrade # NOTE: this upgrades even if there is some typa misconfigured ppa or something
                     # NOTE: we have to do this bc sometimes I'll forget to run the script or something
printf "\033[0m"

printf "\033[90m"
sudo apt-get install alacritty tmux fzf git curl wget
printf "\033[0m"

# Clone and link config

git_clone_location = ~/Projects/

mkdir --parents $git_clone_location
printf "\033[90m"
git clone git@github.com:S-Spektrum-M/config.git $git_clone_location/config
printf "\033[0m"

mkdir --parents ~/.config

echo "Linking Configs"
ln --symbolic $git_clone_location/config/alacritty ~/.config/alacritty                  # Alacritty
ln --symbolic $git_clone_location/config/git/.gitconfig ~/.gitconfig                    # git
ln --symbolic $git_clone_location/config/zsh/.zshrc ~/.zshrc                            # zshrc
ln --symbolic $git_clone_location/config/zsh ~/.zsh                                     # zsh helpers
ln --symbolic $git_clone_location/config/tmux/.tmux.conf ~/.tmux.conf                   # TMUX
echo "Linked Configs"
