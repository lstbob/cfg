export EDITOR='nvim'
export VISUAL='nvim'

export KEYTIMEOUT=1
bindkey -v

# Tab accepts the inline autosuggestion (zsh-autosuggestions) when one is
# visible; otherwise falls back to completion (fzf's if loaded — source this
# file AFTER `eval "$(fzf --zsh)"` so this binding owns Tab).
tab-accept-or-complete() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  elif (( $+widgets[fzf-completion] )); then
    zle fzf-completion
  else
    zle expand-or-complete
  fi
}
zle -N tab-accept-or-complete
bindkey '^I' tab-accept-or-complete
# Keep zsh-autosuggestions from wrapping this widget — its wrapper clears
# POSTDISPLAY before invoking the original, making the check above always false.
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(tab-accept-or-complete)

# In the fzf Ctrl+R history popup, Tab accepts the highlighted entry
# (fzf's default Tab there is multi-select toggle, which does nothing useful).
export FZF_CTRL_R_OPTS="--bind=tab:accept"
