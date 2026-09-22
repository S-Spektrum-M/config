# dotfiles revision 3

## Support Programs
- All platforms
    - Neovim: note: I use my own [mach-nvim](https://www.github.com/S-Spektrum-M/mach-nvim) distribution but the installer is currently only for Linux but not too hard to get up and running on windows
    - Alacritty: note: separate config for Linux (to startup in WSL).
- Linux
    - tmux
    - zsh

## Configurations by Program

### Alacritty
Cross-platform, GPU-accelerated terminal emulator.
- `alacritty/alacritty.toml`: Main configuration entry point for Linux. Imports modular configurations.
- `alacritty/colors.toml`: Color scheme and palette definitions.
- `alacritty/font.toml`: Font families (CommitMono Nerd Font), styles, size, and glyph offsets.
- `alacritty/window.toml`: Window decorations, opacity, padding, and scrollback history.
- `alacritty/keybindings.toml`: Custom keyboard shortcuts and keybindings.
- `alacritty/env.toml`: Terminal environment variable definitions.
- `alacritty/wsl.toml`: WSL terminal shell configuration.
- `alacritty/alacritty_windows.toml`: Windows configuration entrypoint. Imports modular configurations including WSL profile.

### Cppman
C++ manual page viewer.
- `cppman/cppman.cfg`: Configuration for C++ manual pages.

### Codex
Coding-agent UI customization.
- `./codex/themes/blackbird.tmTheme`: Blackbird theme for Codex.

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

### Pi
Coding-agent UI customizations.
- `pi/extensions/mach-dashboard-header.ts`: Replaces pi's startup header with the Mach dashboard banner.
- `pi/extensions/notify.ts`: Sends a desktop notification when pi finishes and is ready for input.
- `pi/extensions/respond.ts`: Opens the last assistant response in `$EDITOR` via `/respond` or Alt+R, then loads the edited text into the input field.
- `pi/themes/blackbird.json`: Blackbird TUI theme matching the canonical Neovim colorscheme.
- `scripts/pi-update-daily`: Updates Pi and its installed extensions.
- `systemd/user/pi-update.timer`: Runs the Pi update script daily and catches up after missed runs.

### Spotify-tui
Spotify in the terminal.
- `spotify-tui/config.yml`: Configuration for spotify-tui.

### Tmux
Terminal multiplexer for Linux.
- `tmux/.tmux.conf`: Custom keybindings (prefix `C-n`), vi-mode for copying with OSC 52 / `scripts/clip`, onedark-inspired colors, fzf session switcher, and integration with vimbridge.

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
