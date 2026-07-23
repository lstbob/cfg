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
