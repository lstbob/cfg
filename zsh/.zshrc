export EDITOR='nvim'
export VISUAL='nvim'

export KEYTIMEOUT=1
bindkey -v

# fzf
eval "$(fzf --zsh)"
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then ls {}; else cat {}; fi'"
