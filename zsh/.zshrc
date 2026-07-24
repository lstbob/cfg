export EDITOR='nvim'
export VISUAL='nvim'

export KEYTIMEOUT=1
bindkey -v

# fzf custom opts (plugin handles key-bindings/completion)
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then ls {}; else cat {}; fi'"
export FZF_CTRL_R_OPTS="--bind=tab:accept"
