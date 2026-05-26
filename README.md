# dotfiles revision 3

## Support Programs
- All platforms
    - neovim; note: I use my own [mach-nvim](https://www.github.com/S-Spektrum-M/mach-nvim) distribution but the installer is currently only for linux but not too hard to get up and running on windows
    - alacritty; note: seperate config for linux(to startup in WSL).
- Linux
    - tmux
    - zsh

## Configurations by Program

### Alacritty
Cross-platform, GPU-accelerated terminal emulator.
- `alacritty/alacritty.toml`: Main configuration for Linux. Uses JetbrainsMonoNL Nerd Font, custom colors, and specific keyboard bindings.
- `alacritty/alacritty_windows.toml`: Windows-specific configuration. Automatically launches wsl.

### Cppman
C++ manual page viewer.
- `cppman/cppman.cfg`: Configuration for C++ manual pages.

### Gh-dash
GitHub CLI dashboard.
- `gh-dash/config.yml`: Settings for the gh-dash layout and features.

### Ghostty
Spiritual port of Alacritty config for testing.
- `ghostty/config`: Setup for fonts, colors (palette matching Alacritty), and window styling.

### Git
Version control system.
- `git/.gitconfig`: Custom Git config with delta for diffs, ssh signing, auto-setup for rebase/push, and several custom aliases (lg1/lg2/lg3 for logs, bb for better branches).
- `git/better-branch.sh`: Script for improved branch viewing.

### Glaze
- `glaze/config.yaml`: Configuration for glaze.

### LSD (LSDeluxe)
Next-generation ls command.
- `lsd/lsd.yaml`: Custom configuration for sorting, colors, and layout for lsd.

### Spotify-tui
Spotify in the terminal.
- `spotify-tui/config.yml`: Configuration for spotify-tui.

### Tmux
Terminal multiplexer for Linux.
- `tmux/.tmux.conf`: Custom keybindings (prefix `C-n`), vi-mode for copying, onedark-inspired colors, fzf session switcher, and integration with vimbridge.

### Yazi
Terminal file manager.
- `yazi/yazi.toml`: Settings for the yazi file manager.
- `yazi/flavors/`: Custom flavors for yazi.

### Zathura
Highly customizable document viewer.
- `zathura/zathurarc`: Configuration for zathura.

### Zsh
Z shell configuration for Linux.
- `zsh/.zshrc`: Main entry point. Sources various modular configuration files.
- `zsh/aliases.zsh`: Command aliases (e.g., `nv` for neovim, `y` for yazi, `ls` for lsd, C++ compiler shortcuts).
- `zsh/projects.zsh`: Project attachment helper (`prat`) to fuzzy-find and attach to projects using tmux.
- `zsh/envvars.zsh`, `zsh/prompt.zsh`, `zsh/fzf-integration.zsh`, `zsh/git-integration.zsh`, `zsh/notes.zsh`, `zsh/cpp-helpers.zsh`, `zsh/tmux-integration.zsh`, `zsh/opts.zsh`: Modular Zsh component scripts for specific features.
