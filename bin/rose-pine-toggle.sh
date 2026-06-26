#!/usr/bin/env bash
# rose-pine-toggle — unified light/dark switch for Neovim + tmux + Alacritty.
# Flips all three between rose-pine "main" (dark) and "dawn" (light).
# Portable: auto-detects WSL vs native Linux to locate the Alacritty config.
# Override the config path anytime with:  ALACRITTY_CONFIG=/path/to/alacritty.toml
# Bound to Ctrl+Shift+B in both bindings-linux.toml and bindings-wsl.toml.
set -uo pipefail

TMUX_CONF="$HOME/.tmux.conf"
TMUX_PLUGIN="$HOME/.local/share/tmux/plugins/tmux-rose-pine/rose-pine.tmux"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# --- Locate the Alacritty config (OS-dependent) ---
if [ -z "${ALACRITTY_CONFIG:-}" ]; then
  if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
    # WSL: Alacritty runs on Windows; config lives under the Windows user's AppData.
    winuser="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"
    ALACRITTY_CONFIG="/mnt/c/Users/${winuser}/AppData/Roaming/alacritty/alacritty.toml"
  else
    ALACRITTY_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/alacritty.toml"
  fi
fi

# --- Decide target mode from Alacritty's active (uncommented) import line ---
if [ -f "$ALACRITTY_CONFIG" ] && grep -qE '^import = .*rose_pine_dawn\.toml' "$ALACRITTY_CONFIG"; then
  mode="dark";  variant="main"; ala_theme="rose_pine.toml"        # currently light -> go dark
else
  mode="light"; variant="dawn"; ala_theme="rose_pine_dawn.toml"   # currently dark -> go light
fi

# --- 1) Alacritty: rewrite the active import's theme file (cat-back keeps the inode
#        so the file watcher fires and live-reloads) ---
if [ -f "$ALACRITTY_CONFIG" ]; then
  tmp="$(mktemp)"
  if sed -E "s#(^import = .*)(rose_pine(_dawn)?|github_[a-z_]+|gruvbox_[a-z_]+)\.toml#\1${ala_theme}#" "$ALACRITTY_CONFIG" > "$tmp"; then
    cat "$tmp" > "$ALACRITTY_CONFIG"
  fi
  rm -f "$tmp"
fi

# --- 2) tmux: persist variant in the config, apply live, re-render the status bar ---
sed -i -E "s#(@rose_pine_variant ')[a-z]+(')#\1${variant}\2#" "$TMUX_CONF" 2>/dev/null || true
if tmux info >/dev/null 2>&1; then
  tmux set -g @rose_pine_variant "$variant"
  tmux run-shell "$TMUX_PLUGIN" >/dev/null 2>&1 || true
  tmux display-message "rose-pine: ${mode}" 2>/dev/null || true
fi

# --- 3) Neovim: tell every running instance to follow (best-effort, non-blocking) ---
shopt -s nullglob
for sock in "$RUNTIME_DIR"/nvim.*; do
  [ -S "$sock" ] || continue
  timeout 2 nvim --server "$sock" --remote-expr "execute('set background=${mode}')" >/dev/null 2>&1 || true
done

echo "Switched to rose-pine ${mode} (variant: ${variant})."
echo "  alacritty config: ${ALACRITTY_CONFIG}"
