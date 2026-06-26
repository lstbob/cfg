#!/usr/bin/env bash
# open-alacritty-config.sh — open the live alacritty.toml in a new tmux nvim window.
# OS-aware: locates the live Alacritty config (Wayland/X11 vs Windows AppData).
# Bound to Ctrl+Comma in both bindings-linux.toml and bindings-wsl.toml.
set -euo pipefail

if grep -qi microsoft /proc/version 2>/dev/null; then
  # WSL: Alacritty runs on Windows; config lives under the Windows user's AppData.
  winuser="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"
  cfg="/mnt/c/Users/${winuser}/AppData/Roaming/alacritty/alacritty.toml"
else
  cfg="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/alacritty.toml"
fi

# Fallback to the repo reference if the generated live file is missing.
[ -f "$cfg" ] || cfg="$HOME/dev/cfg/alacritty/alacritty.toml"

exec tmux new-window "nvim '$cfg'"