#!/bin/bash

# Notes: I went with option 2 with a 2G disk
# systemd service is defined at ~/.config/systemd/user/ccache-ramdisk.service

# ==============================================================================
# ccache Ramdisk Setup Utility
# ==============================================================================
# This script configures ccache to run entirely in RAM for maximum compilation speed.
# It offers three different setup options depending on your preference.
#
# RUNNING THIS SCRIPT:
# Make the script executable and run it:
#   chmod +x setup_ccache_ramdisk.sh
#   ./setup_ccache_ramdisk.sh
# ==============================================================================

set -euo pipefail

# Define variables
CCACHE_DIR="$HOME/.ccache"
PHYSICAL_DIR="$HOME/.ccache_physical"
RAM_DIR="/dev/shm/$USER/ccache"

# Highlight formatting helper
echo_bold() {
    echo -e "\033[1;36m$1\033[0m"
}

echo_success() {
    echo -e "\033[1;32m$1\033[0m"
}

echo_warning() {
    echo -e "\033[1;33m$1\033[0m"
}

echo_error() {
    echo -e "\033[1;31m$1\033[0m"
}

clear
echo "========================================================================"
echo_bold "                   ccache Ramdisk Setup Utility"
echo "========================================================================"
echo "Choose one of the following methods to run ccache in RAM:"
echo ""
echo "1) [Recommended] Transient RAM disk via /dev/shm (No Sudo/Root Required)"
echo "   - Creates a symlink from ~/.ccache to /dev/shm/\$USER/ccache."
echo "   - Fastest setup and completely safe."
echo "   - Note: The cache is cleared on every reboot."
echo ""
echo "2) Persistent RAM disk via /dev/shm + systemd (No Sudo/Root Required)"
echo "   - Keeps a persistent backup in ~/.ccache_physical."
echo "   - Automatically loads it to RAM (/dev/shm) on login/boot."
echo "   - Automatically syncs it back to disk on logout/shutdown."
echo "   - Requires 'rsync' and systemd user services."
echo ""
echo "3) Dedicated /etc/fstab tmpfs Mount (Sudo/Root Required)"
echo "   - Mounts a dedicated tmpfs directly to ~/.ccache."
echo "   - Note: The cache is cleared on every reboot."
echo "========================================================================"
echo ""

read -p "Select option (1, 2, or 3): " choice

# Backup helper function
backup_existing_ccache() {
    if [ -e "$CCACHE_DIR" ]; then
        if [ -L "$CCACHE_DIR" ]; then
            echo_warning "Warning: $CCACHE_DIR is already a symbolic link pointing to $(readlink -f "$CCACHE_DIR")."
            read -p "Do you want to replace it? (y/N): " replace_link
            if [[ "$replace_link" =~ ^[Yy]$ ]]; then
                rm "$CCACHE_DIR"
            else
                echo_error "Aborted."
                exit 1
            fi
        elif [ -d "$CCACHE_DIR" ]; then
            local backup_name="${CCACHE_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
            echo "Backing up existing directory $CCACHE_DIR to $backup_name..."
            mv "$CCACHE_DIR" "$backup_name"
        else
            echo_error "Error: $CCACHE_DIR exists and is not a directory or link. Please manually move it."
            exit 1
        fi
    fi
}

case "$choice" in
    1)
        echo_bold "\n--- Setting up Option 1: Transient RAM disk ---"
        backup_existing_ccache

        # Create RAM directory
        mkdir -p "$RAM_DIR"
        chmod 700 "$RAM_DIR"

        # Link ~/.ccache to the RAM directory
        ln -s "$RAM_DIR" "$CCACHE_DIR"
        echo "Created symlink: $CCACHE_DIR -> $RAM_DIR"

        # Add startup hook to shell configurations so the directory is created on boot
        hook_cmd="mkdir -p /dev/shm/\$USER/ccache 2>/dev/null && chmod 700 /dev/shm/\$USER/ccache 2>/dev/null"

        shell_updated=0
        for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [ -f "$rc" ]; then
                if grep -Fxq "$hook_cmd" "$rc" || grep -q "mkdir -p /dev/shm" "$rc"; then
                    echo "Startup hook already configured in $rc."
                else
                    echo "Appending startup hook to $rc..."
                    echo -e "\n# Ensure ccache ramdisk directory exists on boot\n$hook_cmd" >> "$rc"
                    shell_updated=1
                fi
            fi
        done

        # Suggest ccache configuration size
        if command -v ccache &> /dev/null; then
            read -p "Configure max cache size? (e.g. 2G, 4G) [default: 2G]: " max_size
            max_size=${max_size:-2G}
            ccache -M "$max_size"
            echo "Configured max cache size to $max_size."
        fi

        echo_success "\nSetup Complete!"
        echo "Your ccache is now running in RAM. Any compiled objects will reside in memory."
        if [ "$shell_updated" -eq 1 ]; then
            echo "Note: Please run 'source ~/.bashrc' or 'source ~/.zshrc' (or open a new terminal) to apply the directory recreation hook."
        fi
        ;;

    2)
        echo_bold "\n--- Setting up Option 2: Persistent RAM disk via systemd ---"

        # Verify dependencies
        if ! command -v rsync &> /dev/null; then
            echo_error "Error: 'rsync' is required for Option 2 but was not found."
            echo "Please install it first (e.g., 'sudo apt install rsync' or 'sudo pacman -S rsync')."
            exit 1
        fi

        # Handle ccache transition to physical location
        if [ -e "$CCACHE_DIR" ] && [ ! -L "$CCACHE_DIR" ] && [ -d "$CCACHE_DIR" ]; then
            echo "Moving existing ~/.ccache to ~/.ccache_physical as your physical backup..."
            mv "$CCACHE_DIR" "$PHYSICAL_DIR"
        else
            mkdir -p "$PHYSICAL_DIR"
            chmod 700 "$PHYSICAL_DIR"
        fi

        # Ensure RAM directory exists
        mkdir -p "$RAM_DIR"
        chmod 700 "$RAM_DIR"

        # Create symlink if it doesn't exist
        if [ ! -L "$CCACHE_DIR" ]; then
            if [ -e "$CCACHE_DIR" ]; then
                backup_existing_ccache
            fi
            ln -s "$RAM_DIR" "$CCACHE_DIR"
            echo "Created symlink: $CCACHE_DIR -> $RAM_DIR"
        fi

        # Create systemd user service file
        SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
        mkdir -p "$SYSTEMD_USER_DIR"

        SERVICE_FILE="$SYSTEMD_USER_DIR/ccache-ramdisk.service"
        echo "Creating systemd user service: $SERVICE_FILE"

        # Note the ExecStop safeguard: it only runs rsync if /dev/shm/%u/ccache/tmp exists.
        # This prevents accidental deletions of physical cache if the ramdisk was never initialized.
        cat << 'EOF' > "$SERVICE_FILE"
[Unit]
Description=Sync ccache to RAM on boot/login and save to disk on shutdown/logout
Documentation=https://github.com/ccache/ccache
DefaultDependencies=no

[Service]
Type=oneshot
RemainAfterExit=true
# Load physical cache into RAM on startup
ExecStart=/bin/sh -c 'mkdir -p /dev/shm/%u/ccache && chmod 700 /dev/shm/%u/ccache && if [ -d %h/.ccache_physical ]; then rsync -a --delete %h/.ccache_physical/ /dev/shm/%u/ccache/; fi'
# Save RAM cache back to physical disk on shutdown (safeguarded against empty/uninitialized mount)
ExecStop=/bin/sh -c 'if [ -d /dev/shm/%u/ccache/tmp ]; then mkdir -p %h/.ccache_physical && rsync -a --delete /dev/shm/%u/ccache/ %h/.ccache_physical/; else echo "Warning: RAM cache uninitialized or missing. Skipping sync to protect physical backup."; fi'

[Install]
WantedBy=default.target
EOF

        # Reload, enable and start the systemd service
        echo "Reloading systemd user configuration..."
        systemctl --user daemon-reload

        echo "Enabling and starting ccache-ramdisk service..."
        systemctl --user enable ccache-ramdisk.service
        systemctl --user start ccache-ramdisk.service

        # Suggest ccache configuration size
        if command -v ccache &> /dev/null; then
            read -p "Configure max cache size? (e.g. 2G, 4G) [default: 2G]: " max_size
            max_size=${max_size:-2G}
            ccache -M "$max_size"
            echo "Configured max cache size to $max_size."
        fi

        echo_success "\nSetup Complete!"
        echo "Your ccache is running in RAM and is persistently synced to disk by systemd."
        echo "Check the service status by running:"
        echo "  systemctl --user status ccache-ramdisk.service"
        ;;

    3)
        echo_bold "\n--- Setting up Option 3: Dedicated /etc/fstab tmpfs Mount ---"
        backup_existing_ccache

        # Create mount point
        mkdir -p "$CCACHE_DIR"
        chmod 700 "$CCACHE_DIR"

        read -p "Enter desired RAM cache size (e.g. 2G, 4G, 512M) [default: 2G]: " size
        size=${size:-2G}

        # Fetch system UID and GID for correct ownership inside the mount
        UID_VAL=$(id -u)
        GID_VAL=$(id -g)

        fstab_line="tmpfs  $CCACHE_DIR  tmpfs  defaults,size=$size,uid=$UID_VAL,gid=$GID_VAL,mode=0700  0  0"

        echo ""
        echo "To complete this setup, you need to add the following line to /etc/fstab:"
        echo -e "\033[1;35m$fstab_line\033[0m"
        echo ""

        read -p "Do you want to automatically append this to /etc/fstab and mount it? (Requires sudo) (y/N): " run_sudo
        if [[ "$run_sudo" =~ ^[Yy]$ ]]; then
            echo "Appending entry to /etc/fstab (requires sudo password)..."
            echo "$fstab_line" | sudo tee -a /etc/fstab > /dev/null
            echo "Mounting $CCACHE_DIR..."
            sudo mount "$CCACHE_DIR"
            echo_success "Success! Dedicated tmpfs mounted at $CCACHE_DIR."
        else
            echo "Skipped automatic modification."
            echo "To complete setup manually, run:"
            echo "  echo \"$fstab_line\" | sudo tee -a /etc/fstab"
            echo "  sudo mount \"$CCACHE_DIR\""
        fi

        # Suggest ccache configuration size
        if command -v ccache &> /dev/null; then
            ccache -M "$size"
            echo "Configured max cache size to $size."
        fi

        echo_success "\nSetup Complete!"
        ;;

    *)
        echo_error "Invalid choice: '$choice'. Exiting."
        exit 1
        ;;
esac
