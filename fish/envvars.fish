# this file should be in ~/.config/fish/envvars.fish

set -gx EDITOR '/usr/local/bin/nvim'
set -gx VISUAL "$EDITOR"
set -gx GITPATH '/usr/bin/git'
set -gx MANPAGER 'nvim +Man!'

if not set -q PROJECTS_DIR; or test -z "$PROJECTS_DIR"
    set -gx PROJECTS_DIR "$HOME/Projects"
end
if not set -q DOTFILES_DIR; or test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$PROJECTS_DIR/config"
end

# Tool-specific Exports
set -l _cpu_count 0
if test -r /sys/devices/system/cpu/online
    set -l _cpu_online (string trim < /sys/devices/system/cpu/online)
    for _cpu_range in (string split ',' -- $_cpu_online)
        if string match -q '*-*' -- $_cpu_range
            set -l _bounds (string split '-' -- $_cpu_range)
            set _cpu_count (math $_cpu_count + $_bounds[2] - $_bounds[1] + 1)
        else if test -n "$_cpu_range"
            set _cpu_count (math $_cpu_count + 1)
        end
    end
end
test $_cpu_count -gt 0; and set -gx MAKEFLAGS "-j$_cpu_count"

set -gx DENO_INSTALL "$HOME/.deno"
set -gx VCPKG_ROOT "$HOME/dev/vcpkg"
set -gx GOPATH "$HOME/go"

# Library Paths
if set -q LD_LIBRARY_PATH; and test -n "$LD_LIBRARY_PATH"
    set -gx LD_LIBRARY_PATH "/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH"
else
    set -gx LD_LIBRARY_PATH "/usr/local/cuda-12.4/lib64"
end

# NVM & Bun Setup
set -gx NVM_DIR "$HOME/.nvm"
set -gx BUN_INSTALL "$HOME/.bun"

function nvm
    if not test -s "$NVM_DIR/nvm.sh"
        echo "nvm: $NVM_DIR/nvm.sh not found" >&2
        return 1
    end
    set -l new_node_bin (bash -c 'source "$NVM_DIR/nvm.sh" && nvm "$@" >&2 && command -v node' -- $argv)
    set -l exit_code $status
    if test $exit_code -eq 0 -a -n "$new_node_bin"
        set -l new_bin_dir (path dirname -- "$new_node_bin")
        set -l cleaned_path
        for p in $PATH
            if not string match -q "$NVM_DIR/versions/node/*/bin" -- "$p"
                set -a cleaned_path "$p"
            end
        end
        set -gx PATH "$new_bin_dir" $cleaned_path
    end
    return $exit_code
end

# Resolve the active node bin dir without loading nvm.
# Prefer `nvm alias default`; fall back to the highest installed version.
set -l NODE_BIN ""
if test -r "$NVM_DIR/alias/default"
    # nvm stores the alias without a leading 'v' (e.g. "24.2.0") but dirs have it ("v24.2.0")
    set -l _node_default (string trim < "$NVM_DIR/alias/default")
    set -l _node_ver (string replace -r '^v' '' -- "$_node_default")
    for _cand in "$_node_default" "v$_node_ver"
        if test -d "$NVM_DIR/versions/node/$_cand/bin"
            set NODE_BIN "$NVM_DIR/versions/node/$_cand/bin"
            break
        end
    end
end
if test -z "$NODE_BIN"
    set -l _node_dirs (path sort -- $NVM_DIR/versions/node/*/bin 2>/dev/null)
    if test (count $_node_dirs) -gt 0
        set NODE_BIN $_node_dirs[-1]
    end
end

# Path Setup
set -l _prepend_paths \
    "$HOME/Projects/axon/build/common-release/" \
    "$HOME/.local/lib/python3.10/site-packages" \
    "$HOME/.local/bin" \
    "$DENO_INSTALL/bin" \
    "$HOME/bin" \
    "$HOME/.cargo/bin" \
    "/usr/local/bin" \
    "/usr/local/cuda/bin" \
    "/usr/local/cuda-12.4/bin" \
    "/snap/bin" \
    "$VCPKG_ROOT" \
    "$GOPATH/bin" \
    "$PROJECTS_DIR/catalyst/catalyst/build/common-ccache-release" \
    "$PROJECTS_DIR/catalyst/cob/build/common-ccache-release" \
    "$PROJECTS_DIR/catalyst/crab/build/common-ccache-release" \
    "$PROJECTS_DIR/catalyst/catalyst-tui/build/common" \
    "$PROJECTS_DIR/agents-md-generator/"

if test -n "$NODE_BIN"
    set -a _prepend_paths "$NODE_BIN"
end

set -a _prepend_paths \
    "$BUN_INSTALL/bin" \
    "$HOME/.lmstudio/bin"

set -gx PATH $_prepend_paths $PATH

if set -q XDG_DATA_DIRS; and test -n "$XDG_DATA_DIRS"
    set -gx XDG_DATA_DIRS "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
else
    set -gx XDG_DATA_DIRS "/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
end

set -gx CODING_AGENT "pi"
