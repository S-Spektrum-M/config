setopt PROMPT_SUBST # Needed for prompt command substitution
setopt AUTO_CD      # Change directory without typing 'cd'
setopt SHARE_HISTORY # Share history between all sessions
bindkey -v
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
