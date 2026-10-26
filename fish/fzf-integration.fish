set -gx FZF_DEFAULT_OPTS '--color=fg:#f8f8f2,bg:#080a0c,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
set -gx FZF_ALT_C_OPTS "--walker=dir,follow"

# fzf default command (prefers ripgrep, then fd)
if command -q rg
    set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --glob "!.git"'
else if command -q fdfind
    set -gx FZF_DEFAULT_COMMAND 'fdfind --type f --hidden --exclude .git'
else if command -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
end

# Use bottom tmux split for Ctrl+R history search when inside tmux
if set -q TMUX; and test -n "$TMUX"
    set -gx FZF_CTRL_R_OPTS "--tmux bottom"
end

function fzf-open-widget
    set -l find_cmd
    if command -q fd
        set find_cmd "fd --type f --hidden --exclude .git --exclude build --exclude dist --exclude target --exclude out --exclude .next --exclude .venv --exclude venv --exclude node_modules"
    else if command -q fdfind
        set find_cmd "fdfind --type f --hidden --exclude .git --exclude build --exclude dist --exclude target --exclude out --exclude .next --exclude .venv --exclude venv --exclude node_modules"
    else
        set find_cmd "find . \( -name .git -o -name build -o -name .next -o -name node_modules -o -name dist -o -name target -o -name .venv -o -name venv -o -name out \) -prune -o -type f -print"
    end

    set -l file
    if set -q TMUX; and test -n "$TMUX"
        set file (eval "$find_cmd" 2>/dev/null | fzf --tmux=90%,90% --preview "batcat --color=always {}")
    else
        set file (eval "$find_cmd" 2>/dev/null | fzf --preview "batcat --color=always {}")
    end

    if test -n "$file"
        set -l editor_cmd (set -q EDITOR; and test -n "$EDITOR"; and string split ' ' -- "$EDITOR"; or echo "nvim")
        $editor_cmd "$file"
    end
    commandline -f repaint
end

# Cache and lazily load fzf keybindings/completions on first prompt
if status is-interactive
    function __fish_init_fzf_bindings --on-event fish_prompt
        functions -e __fish_init_fzf_bindings
        if command -q fzf
            set -l fzf_cache "$HOME/.cache/fish/fzf-init.fish"
            if not test -s "$fzf_cache"
                mkdir -p "$HOME/.cache/fish"
                fzf --fish > "$fzf_cache"
            end
            source "$fzf_cache"
        end
        bind \co fzf-open-widget
        bind -M insert \co fzf-open-widget
        if functions -q prat-widget
            bind \cp prat-widget
            bind -M insert \cp prat-widget
        end
    end
end
