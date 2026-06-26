#!/usr/bin/env bash
#
# setup.sh — unified config installer for the cfg dotfiles repo.
# Run this inside Debian bash on EITHER:
#   - native Debian Trixie (GNOME/Wayland, Alacritty as a native Linux app), OR
#   - Windows 11 + WSL Debian Trixie (Alacritty installed as a Windows app).
#
# It wires configs (symlinks on Linux, copies for the Windows Alacritty bits),
# clones tmux plugins, installs the alacritty-config helper,
# bootstraps nvim plugins, and (on native Linux) installs the GNOME Dash launchers.
#
# Prerequisites must be installed MANUALLY first (this script does NOT apt-install
# anything; it checks and fails fast with a clear message if something is missing):
#   sudo apt install -y tmux ripgrep fzf build-essential git curl xclip
#   # Alacritty:  cargo install alacritty            (native Linux)
#   #             winget install Alacritty.Alacritty (Windows, for the WSL box)
#   # opencode:    curl -fsSL https://opencode.ai/install | bash
#   # Neovim >= 0.11 (tarball; apt on trixie is too old)
#   git clone git@github.com:lstbob/cfg <CFG_DIR>   # /mnt/data/dev/cfg | ~/dev/cfg
#
# Usage:  ./setup.sh           (CFG_DIR = this script's directory)
#         CFG_DIR=/path ./setup.sh
#
set -euo pipefail

CFG_DIR="${CFG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
IS_WSL=0
if grep -qi microsoft /proc/version 2>/dev/null; then IS_WSL=1; fi

PLUGINS_DIR="$HOME/.local/share/tmux/plugins"
LOCAL_BIN="$HOME/.local/bin"
NVIM_CONFIG="$HOME/.config/nvim"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '[setup] %s\n' "$*"; }
die()   { red "[setup] error: $*"; exit 1; }

# --- repo + OS sanity -----------------------------------------------------------
[ -d "$CFG_DIR/alacritty" ] && [ -d "$CFG_DIR/nvim" ] && [ -d "$CFG_DIR/tmux" ] \
  || die "CFG_DIR ($CFG_DIR) doesn't look like the cfg repo (missing alacritty/nvim/tmux)."
[ -f "$CFG_DIR/setup.sh" ] || die "run setup.sh from inside the cfg repo (or set CFG_DIR=)."
if [ "$IS_WSL" = 1 ]; then bold "Detected: WSL (Windows 11 + Debian Trixie)."; else bold "Detected: native Debian Trixie."; fi

# --- prerequisite checks (fail fast; manual install expected) -------------------
need() {
  command -v "$1" >/dev/null 2>&1 || { red "[setup] MISSING prerequisite: $1 — install it first (see header of this script)."; MISSING=1; }
}
MISSING=0
need tmux; need rg; need fzf; need make; need cc; need nvim; need curl
if ! command -v nvim >/dev/null 2>&1 || ! nvim --version | head -1 | grep -qE '0\.1[1-9]|[1-9]\.'; then
  red "[setup] Neovim >= 0.11 required (uses native vim.lsp). Install the upstream tarball."
  MISSING=1
fi
if [ "$IS_WSL" = 1 ]; then
  command -v alacritty.exe >/dev/null 2>&1 || ls /mnt/c/Users/*/AppData/Local/Microsoft/WindowsApps/alacritty.exe >/dev/null 2>&1 \
    || { red "[setup] Alacritty not found on Windows (winget install Alacritty.Alacritty)."; MISSING=1; }
else
  command -v alacritty >/dev/null 2>&1 || [ -x "$HOME/.cargo/bin/alacritty" ] \
    || { red "[setup] Alacritty not found (cargo install alacritty)."; MISSING=1; }
fi
command -v opencode >/dev/null 2>&1 || [ -x "$HOME/.opencode/bin/opencode" ] \
  || info "note: opencode binary not on PATH (install via curl .../install | bash) — devsetup launchers may break for the opencode session."
[ "$MISSING" = 0 ] || die "one or more prerequisites missing (see above). Install them and re-run."
green "prerequisites present."

# --- directories ----------------------------------------------------------------
mkdir -p "$PLUGINS_DIR" "$LOCAL_BIN" "$HOME/.config/alacritty" "$NVIM_CONFIG"

# --- tmux plugins (clone if missing) -------------------------------------------
clone_plugin() { # <repo-url> <dir-name>
  local url="$1" name="$2" dest="$PLUGINS_DIR/$2"
  if [ -d "$dest/.git" ]; then info "tmux plugin present: $name"; else
    info "cloning tmux plugin: $name ..."
    git clone --depth 1 "$url" "$dest" || die "failed to clone $url"
  fi
}
clone_plugin https://github.com/tmux-plugins/tmux-resurrect tmux-resurrect
clone_plugin https://github.com/rose-pine/tmux tmux-rose-pine

# --- Debian-side configs: symlink into the repo (run on both OSes) ---------------
link() { # <target> <link-path>
  local tgt="$1" l="$2"
  mkdir -p "$(dirname "$l")"
  if [ -e "$l" ] && [ ! -L "$l" ]; then
    local bk="$l.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$l" "$bk"; info "backed up existing $l -> $bk"
  fi
  ln -sfn "$tgt" "$l"
  info "symlinked $l -> $tgt"
}
link "$CFG_DIR/nvim" "$NVIM_CONFIG"
link "$CFG_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

if ! grep -q "cfg/bash/.bashrc" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# fzf supplement from cfg repo\n[ -f %s/bash/.bashrc ] && source %s/bash/.bashrc\n' "$CFG_DIR" "$CFG_DIR" >> "$HOME/.bashrc"
  info "appended bash supplement to ~/.bashrc"
fi

# --- install helper scripts to ~/.local/bin ------------------------------------
install_bin() { # <src>
  local name; name="$(basename "$1")"
  cp -f "$1" "$LOCAL_BIN/$name" && chmod +x "$LOCAL_BIN/$name"
  info "installed $LOCAL_BIN/$name"
}
install_bin "$CFG_DIR/bin/open-alacritty-config.sh"

# --- Alacritty config -----------------------------------------------------------
if [ "$IS_WSL" = 1 ]; then
  # Alacritty runs on Windows and can't follow Linux symlinks -> copy files.
  winuser="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"
  ALA_DIR="/mnt/c/Users/${winuser}/AppData/Roaming/alacritty"
  mkdir -p "$ALA_DIR/themes/themes"
  cp -f "$CFG_DIR/alacritty/base.toml" "$ALA_DIR/base.toml"
  cp -f "$CFG_DIR/alacritty/bindings-wsl.toml" "$ALA_DIR/bindings-wsl.toml"
  # only the color-scheme tomls are needed (alacritty-theme ships ~190 preview PNGs)
  cp -f "$CFG_DIR/alacritty/themes/themes/"*.toml "$ALA_DIR/themes/themes/" 2>/dev/null || true
  info "copied base/bindings + theme files to $ALA_DIR"
else
  ALA_DIR="$HOME/.config/alacritty"
  link "$CFG_DIR/alacritty/base.toml" "$ALA_DIR/base.toml"
  link "$CFG_DIR/alacritty/bindings-linux.toml" "$ALA_DIR/bindings-linux.toml"
  link "$CFG_DIR/alacritty/themes" "$ALA_DIR/themes"
  info "symlinked alacritty base/bindings/themes"
fi

# Generate the top-level alacritty.toml (imports base + OS bindings + rose-pine theme).
ALA_TOP="$ALA_DIR/alacritty.toml"
if [ "$IS_WSL" = 1 ]; then
  # Windows: ~ expands to %USERPROFILE% inside Alacritty; use backslash paths.
  cat > "$ALA_TOP" <<'EOF'
# Generated by setup.sh (WSL). Edits here are live and not tracked by git.
[general]
import = [
  "~\\AppData\\Roaming\\alacritty\\base.toml",
  "~\\AppData\\Roaming\\alacritty\\bindings-wsl.toml",
  "~\\AppData\\Roaming\\alacritty\\themes\\themes\\rose_pine.toml",
]
EOF
else
  cat > "$ALA_TOP" <<'EOF'
# Generated by setup.sh (native Linux). Edits here are live and not tracked by git.
[general]
import = [
  "~/.config/alacritty/base.toml",
  "~/.config/alacritty/bindings-linux.toml",
  "~/.config/alacritty/themes/themes/rose_pine.toml",
]
EOF
fi
info "generated $ALA_TOP"

# --- nvim plugin bootstrap (lazy.nvim installs rose-pine + builds fzf-native) --
info "bootstrapping nvim plugins (lazy.nvim sync) ..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || info "nvim headless sync returned non-zero — re-run :Lazy sync inside nvim if plugins look absent."

# --- OS-specific tail -----------------------------------------------------------
if [ "$IS_WSL" = 1 ]; then
  bold "WSL setup complete. Remaining MANUAL steps:"
  echo "  1. Ensure Alacritty is installed on Windows (winget install Alacritty.Alacritty)."
  echo "  2. (Re)start Alacritty on Windows; it reads %APPDATA%\\alacritty\\alacritty.toml."
  echo "  3. In a WSL tmux session: tmux source-file ~/.tmux.conf  (to pick up new prefix/theme)."
  echo "  4. Open nvim once and run :Lazy sync if checks complained."
  echo "  5. (optional) pin Alacritty to the Windows taskbar."
else
  # native Linux: install the GNOME Dash launchers for dev/opencode tmux sessions.
  if [ -x "$CFG_DIR/devsetup/install.sh" ]; then
    info "installing GNOME Dash launchers ..."
    "$CFG_DIR/devsetup/install.sh" || info "devsetup/install.sh returned non-zero (alacritty/tmux prereq?) — see its output above."
  fi
  bold "Native Linux setup complete. Remaining MANUAL steps:"
  echo "  1. Restart Alacritty (or any running instance) to pick up the new config."
  echo "  2. In tmux: tmux source-file ~/.tmux.conf  (or restart tmux) for new prefix/theme."
  echo "  3. Open Activities -> launch 'Dev (tmux)' & 'Opencode (tmux)' once, right-click -> Pin to Dash."
  echo "  4. Open nvim and run :Lazy sync / :checkhealth telescope if anything looks off."
fi

bold "Done. Verify:"
echo "  tmux ls                       # tmux sessions (after first launch)"
echo "  tmux show -g prefix           # expect: M-Space"
echo "  tmux show -g @rose_pine_variant  # expect: main"
echo "  readlink ~/.config/nvim ~/.tmux.conf  # -> points into the cfg repo"
echo "  nvim -c ':colorscheme' +qa    # expect: rose-pine"