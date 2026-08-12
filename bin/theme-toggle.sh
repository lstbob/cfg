#!/usr/bin/env bash
# theme-toggle -- cycle the cfg dev stack between the two health-oriented
# palettes: "dark" (soft neutral-gray; easy in a dim room) and "light"
# (Solarized Light warm paper; easy in a bright room / daytime). Both are
# plugin-free / import-free; this script just repoints symlinks and re-applies
# a few live colours. Bound to Ctrl+Shift+B (alacritty bindings-*.toml).
#
# Touches, in one shot:  the shared state file, Alacritty base config, tmux
# status, running Neovim instances (selection bg), and the lazygit config
# symlink. Shells (zsh/bash) need a restart to pick up terminal colours;
# running lazygit needs a restart too.
#
# Shared state:  ~/.config/cfg-theme   ("dark" | "light"; default dark)
# Portable: auto-detects WSL vs native Linux for the Alacritty config path.
set -uo pipefail

STATE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/cfg-theme"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
# Resolve the repo root from this script's real location (follow symlinks, so a
# symlinked install in ~/.local/bin still finds the repo). Falls back to the
# known checkout path so a copied install works too. Configs always deploy under
# ~/.config and point into the repo -- never under ~/.local.
CFG_DIR=""
_self="${BASH_SOURCE[0]:-$0}"
if [ -L "$_self" ]; then
  _dir="$(cd "$(dirname "$(readlink -f "$_self")")/.." && pwd)"
  [ -d "$_dir/alacritty" ] && [ -d "$_dir/tmux" ] && CFG_DIR="$_dir"
fi
if [ -z "$CFG_DIR" ]; then
  for _cand in "$HOME/dev/cfg" "$HOME/cfg" "/mnt/data/dev/cfg"; do
    if [ -d "$_cand/alacritty" ] && [ -d "$_cand/tmux" ]; then CFG_DIR="$_cand"; break; fi
  done
fi
[ -n "$CFG_DIR" ] || { echo "theme-toggle: cannot locate the cfg repo (looked via script path + ~/dev/cfg, ~/cfg, /mnt/data/dev/cfg)." >&2; exit 1; }
IS_WSL=0
if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then IS_WSL=1; fi

# --- locate the live Alacritty dir (OS-dependent) ------------------------------
if [ "$IS_WSL" = 1 ]; then
  winuser="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"
  ALA_DIR="/mnt/c/Users/${winuser}/AppData/Roaming/alacritty"
else
  ALA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
fi

# --- decide target theme from the shared state file ----------------------------
current="$(cat "$STATE_FILE" 2>/dev/null || true)"
if [ "$current" = "light" ]; then
  theme="dark"
else
  theme="light"
fi

# --- 1) persist shared state (read by fresh shells + nvim/tmux at startup) ----
mkdir -p "$(dirname "$STATE_FILE")"
printf '%s\n' "$theme" > "$STATE_FILE"

# --- 2) Alacritty: repoint the deployed base.toml to the right repo file -------
#    native Linux: deployed base.toml is a symlink -> flip its target.
#    WSL: deployed base.toml is a copy -> overwrite it from the chosen repo file.
if [ -d "$ALA_DIR" ]; then
  if [ "$IS_WSL" = 1 ]; then
    src="$CFG_DIR/alacritty/base.toml"
    [ "$theme" = "light" ] && src="$CFG_DIR/alacritty/base-light.toml"
    cp -f "$src" "$ALA_DIR/base.toml"
    # keep base-light.toml deployed too so a future dark->light toggle can copy it
    cp -f "$CFG_DIR/alacritty/base-light.toml" "$ALA_DIR/base-light.toml" 2>/dev/null || true
  else
    target="$CFG_DIR/alacritty/base.toml"
    [ "$theme" = "light" ] && target="$CFG_DIR/alacritty/base-light.toml"
    ln -sfn "$target" "$ALA_DIR/base.toml"
  fi
  # nudge Alacritty to live-reload: rewriting the file mtime via cp/ln is enough;
  # Alacritty watches base.toml. (On native the symlink target change is detected.)
fi

# --- 3) tmux: re-source .tmux.conf; its if-shell branch picks the right status
#        fragment (~/.tmux-dark.conf | ~/.tmux-light.conf) and repaints live. ---
if tmux info >/dev/null 2>&1; then
  tmux source-file "$HOME/.tmux.conf" >/dev/null 2>&1 || true
  tmux display-message "theme: ${theme}" 2>/dev/null || true
fi

# --- 4) Neovim: flip `background` so the built-in habamax colorscheme repaints
#        syntax text to match the new terminal. Setting `background` re-applies
#        the current colorscheme and fires ColorScheme, which our autocmd
#        (registered in core/options.lua) catches to re-apply transparency +
#        float/selection bgs. We also apply explicitly in case the value didn't
#        change (no event). Fresh nvim reads the state file at startup. Note: do
#        NOT call `:colorscheme default` -- on nvim 0.12 the built-in is
#        `habamax`, and `vim.o.background` alone re-applies it correctly. ------
shopt -s nullglob
if [ "$theme" = "light" ]; then
  sel_bg="#eee8d5"; float_bg="#efeadb"
else
  sel_bg="#3c3c3c"; float_bg="#252525"
fi
local_snippet="vim.g.cfg_theme='${theme}';vim.o.background='${theme}';vim.api.nvim_set_hl(0,'Normal',{bg='none'});vim.api.nvim_set_hl(0,'NormalFloat',{bg='${float_bg}'});vim.api.nvim_set_hl(0,'FloatBorder',{bg='${float_bg}'});vim.api.nvim_set_hl(0,'Visual',{bg='${sel_bg}'});vim.api.nvim_set_hl(0,'PmenuSel',{bg='${sel_bg}'});vim.api.nvim_set_hl(0,'TelescopeSelection',{bg='${sel_bg}'}))"
for sock in "$RUNTIME_DIR"/nvim.*; do
  [ -S "$sock" ] || continue
  timeout 2 nvim --server "$sock" --remote-expr "execute('lua ${local_snippet}')" >/dev/null 2>&1 || true
done

# --- 5) lazygit: repoint the deployed config symlink. Running lazygit keeps its
#        old colours; next launch picks up the new one. -------------------------
LG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit"
mkdir -p "$LG_DIR" 2>/dev/null || true
lg_src="$CFG_DIR/lazygit/config.yml"
[ "$theme" = "light" ] && lg_src="$CFG_DIR/lazygit/config-light.yml"
ln -sfn "$lg_src" "$LG_DIR/config.yml" 2>/dev/null || true

echo "Switched to ${theme}."
echo "  state file:  ${STATE_FILE}"
echo "  alacritty:   ${ALA_DIR}/base.toml -> $([ "$theme" = light ] && echo base-light.toml || echo base.toml)"
echo "  nvim sel bg: ${sel_bg}"
echo "  lazygit:     ${lg_src}"
echo "  note: start a new shell + restart lazygit for the new palette to fully apply."