export EDITOR='nvim'
export VISUAL='nvim'

export PATH="$HOME/.opencode/bin:$PATH"

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

# Monochrome prompt (white on black via the terminal palette): current dir +
# git branch + dirty marker + prompt char. This runs after oh-my-zsh loads
# ~/.zshrc's theme (e.g. px-rose-pine) and overrides PROMPT, so the live
# theme is neutralised without editing the user's ~/.zshrc.
ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""
PROMPT='%~$(git_prompt_info) %# '
RPROMPT=''

# Remove all remaining colors from the shell. Both plugins are loaded by
# oh-my-zsh (plugins=() in ~/.zshrc) BEFORE this file runs, but they re-read
# their state at paint time, so overriding here neutralises them:
#  - zsh-syntax-highlighting: stop painting commands green/red/etc.
ZSH_HIGHLIGHT_HIGHLIGHTERS=()
#  - zsh-autosuggestions: no grey tint on inline suggestions (plain white)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=white'
