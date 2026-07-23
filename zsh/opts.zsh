setopt PROMPT_SUBST # Needed for prompt command substitution
setopt AUTO_CD      # Change directory without typing 'cd'
setopt SHARE_HISTORY # Share history between all sessions
bindkey -v
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit

_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
_zcompcheck="${_zcompdump}.last-check"
_zcompcheck_expired=(${~_zcompcheck}(Nmh+24))

# Audit completion directories once per day. Between audits, skip the security
# scan and load the compiled completion dump.
if [[ ! -s "$_zcompdump" ||
      ! -e "$_zcompcheck" ||
      ${#_zcompcheck_expired} -ne 0 ]]; then
    compinit -i -d "$_zcompdump"
    : >| "$_zcompcheck"
    zcompile -R "$_zcompdump"
else
    compinit -C -d "$_zcompdump"
fi

unset _zcompdump _zcompcheck _zcompcheck_expired
