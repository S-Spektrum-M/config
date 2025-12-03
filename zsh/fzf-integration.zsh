export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#080a0c,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Source FZF keybindings and completions if they exist
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

fzf-open-widget() {
      if [ -n "$TMUX" ]; then
        file=$(find . -type f -not -path '*/.git/*' 2>/dev/null | fzf --tmux --preview "batcat --color=always {}")
      else
        file=$(find . -type f -not -path '*/.git/*' 2>/dev/null | fzf --preview "batcat --color=always {}")
      fi
      if [[ -n "$file" ]]; then
        $EDITOR $file
      fi
}

zle -N fzf-open-widget
bindkey '^o' fzf-open-widget

# copied from the default fzf.zsh but with TMUX mode if neeeded
fzf-history-custom-widget() {
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
    # Ensure the module is loaded if not already, and the required features, such
    # as the associative 'history' array, which maps event numbers to full history
    # lines, are set. Also, make sure Perl is installed for multi-line output.
    if [ -n "$TMUX" ]; then
        if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
            selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
                perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
                FZF_DEFAULT_OPTS=$(__fzf_defaults "" "--tmux=50% -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m --read0") \
                FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))" else
            selected="$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
                FZF_DEFAULT_OPTS=$(__fzf_defaults "" "--tmux=50% -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m") \
                FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
        fi
    else
        if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
            selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
                perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
                FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m --read0") \
                FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
            else
                selected="$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
                    FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m") \
                    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
        fi
    fi
    local ret=$?
    if [ -n "$selected" ]; then
        if [[ $(awk '{print $1; exit}' <<< "$selected") =~ ^[1-9][0-9]* ]]; then
            zle vi-fetch-history -n $MATCH
        else # selected is a custom query, not from history
            LBUFFER="$selected"
        fi
    fi
    zle reset-prompt
    return $ret
}

zle -N fzf-history-custom-widget
bindkey '^R' fzf-history-custom-widget
