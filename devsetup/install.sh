#!/usr/bin/env bash
#
# devsetup/install.sh — install the Alacritty dash launchers for the
# "dev" and "opencode" tmux sessions on GNOME/Wayland.
#
# Scope: copy the two .desktop files into ~/.local/share/applications,
# install the two icons into the user hicolor icon space, and refresh
# the desktop/icon caches. It does NOT symlink the alacritty/tmux/
# bash/nvim configs from this repo — see devsetup/README.md for that.
#
# Idempotent: safe to re-run.
#
set -euo pipefail

APPS_DIR="${HOME}/.local/share/applications"
ICONS_DIR="${HOME}/.local/share/icons/hicolor"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NVIM_ICON_SRC="/usr/share/icons/hicolor/128x128/apps/nvim.png"
NVIM_ICON_DST="${ICONS_DIR}/128x128/apps/alacritty-dev.png"
OPENCODE_ICON_URL="https://opencode.ai/apple-touch-icon-v3.png"
OPENCODE_ICON_DST="${ICONS_DIR}/256x256/apps/alacritty-opencode.png"

err()  { echo "install.sh: error: $*" >&2; }
info() { echo "install.sh: $*"; }

# --- prerequisites ----------------------------------------------------------

if [[ ! -x "${HOME}/.cargo/bin/alacritty" ]]; then
  err "alacritty not found at ${HOME}/.cargo/bin/alacritty (install via cargo first)."
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  err "tmux not found on PATH (install it first: sudo apt install tmux)."
  exit 1
fi

if [[ ! -d /mnt/data/dev ]]; then
  err "/mnt/data/dev does not exist. Create it (and git clone your cfg repo there) before running this."
  exit 1
fi

if [[ ! -f "${NVIM_ICON_SRC}" ]]; then
  err "neovim icon not found at ${NVIM_ICON_SRC}. Install neovim (sudo apt install neovim) so the dev launcher can reuse its icon."
  exit 1
fi

# --- prepare dirs ------------------------------------------------------------

mkdir -p "${APPS_DIR}" \
         "${ICONS_DIR}/128x128/apps" \
         "${ICONS_DIR}/256x256/apps"

# --- .desktop files ----------------------------------------------------------

for f in alacritty-dev.desktop alacritty-opencode.desktop; do
  src="${SCRIPT_DIR}/${f}"
  dst="${APPS_DIR}/${f}"
  [[ -f "${src}" ]] || { err "missing ${src}"; exit 1; }
  cp -f "${src}" "${dst}"
  info "installed ${dst}"
  if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "${dst}" || err "validation failed for ${dst} (continuing)"
  fi
done

# --- icons -------------------------------------------------------------------

cp -f "${NVIM_ICON_SRC}" "${NVIM_ICON_DST}"
info "installed nvim-derived icon -> ${NVIM_ICON_DST}"

if command -v curl >/dev/null 2>&1; then
  if curl -fsSL "${OPENCODE_ICON_URL}" -o "${OPENCODE_ICON_DST}"; then
    info "downloaded opencode icon -> ${OPENCODE_ICON_DST}"
  else
    err "failed to download opencode icon from ${OPENCODE_ICON_URL} (network issue?). The opencode launcher will have no icon until you place a PNG at ${OPENCODE_ICON_DST}."
  fi
else
  err "curl not found; cannot download opencode icon. Manually fetch ${OPENCODE_ICON_URL} -> ${OPENCODE_ICON_DST}."
fi

# --- cache refresh -----------------------------------------------------------

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "${APPS_DIR}" 2>/dev/null || true
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  # hicolor is a system theme; gtk-update-icon-cache may warn about a missing
  # index.theme at the user path. That warning is harmless — GNOME still finds
  # user-hicolor icons via XDG fallback. Force a cache rebuild:
  gtk-update-icon-cache -f "${ICONS_DIR}" 2>/dev/null || true
fi

info "done. Open Activities (Super), launch 'Dev (tmux)' and 'Opencode (tmux)' once,"
info "then right-click each running icon -> 'Pin to Dash'."
info "Verify: tmux ls  should show sessions: dev, opencode."