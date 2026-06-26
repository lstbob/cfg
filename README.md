# cfg — personal dotfiles

Config files for my Debian Trixie / GNOME (Wayland) dev machine. Alacritty is
the active terminal, neovim is the editor, and two Alacritty dash launchers
open persistent `tmux` sessions in `/mnt/data/dev`.

There is **no bootstrap script** for the core configs — setup is manual
symlinks. The only installer in this repo is `devsetup/install.sh`, which
handles the two GNOME Dash launchers and their icons.

## Layout

| Path              | What it is                                              | Docs                          |
|-------------------|---------------------------------------------------------|-------------------------------|
| `alacritty/`      | Active terminal: `alacritty.toml` + vendored themes (~230) | — (see `alacritty/alacritty.toml`) |
| `bash/`           | fzf **supplement** (not a full bashrc)                  | —                             |
| `tmux/`           | Minimal `tmux.conf` (prefix `Alt+b`, mouse, vi, 1-indexed, no plugins) | —                             |
| `nvim/`           | Neovim config: lazy.nvim, native `vim.lsp`, C#/.NET-first | [`nvim/README.md`](nvim/README.md), [`nvim/SETUP.md`](nvim/SETUP.md) |
| `kitty/`          | Legacy/optional terminal (superseded by alacritty)     | —                             |
| `devsetup/`       | Alacritty Dash launchers for `dev` + `opencode` tmux sessions | [`devsetup/README.md`](devsetup/README.md) |
| `git.txt`         | Personal SSH/git cheat-sheet (not a deployed config)   | —                             |

## Quick setup (manual symlinks)

```bash
# prerequisites
sudo apt install -y tmux neovim ripgrep curl build-essential git
cargo install alacritty          # -> ~/.cargo/bin/alacritty (>= 0.17)
curl -fsSL https://opencode.ai/install | bash

# clone
git clone git@github.com:lstbob/cfg /mnt/data/dev/cfg

# symlinks (create ~/.config dirs first if they don't exist)
ln -sf /mnt/data/dev/cfg/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -sfn /mnt/data/dev/cfg/alacritty/themes      ~/.config/alacritty/themes
ln -sf /mnt/data/dev/cfg/tmux/.tmux.conf        ~/.tmux.conf
ln -sfn /mnt/data/dev/cfg/nvim                  ~/.config/nvim

# bash is a supplement — source it from your real ~/.bashrc
printf '\n[ -f /mnt/data/dev/cfg/bash/.bashrc ] && source /mnt/data/dev/cfg/bash/.bashrc\n' >> ~/.bashrc

# dash launchers
cd /mnt/data/dev/cfg/devsetup && ./install.sh
```

See [`devsetup/README.md`](devsetup/README.md) for the full reproduction guide
(including pinning to the GNOME Dash) and [`nvim/README.md`](nvim/README.md)
for the editor's dependencies (.NET 10 SDK, Go, clang, Node.js, …).

## Notable design choices

- **Alacritty** fullscreen + 0.85 opacity, gruvbox_dark; config-edit hotkeys
  (`Ctrl+,` / `.` / `/`) open the alacritty/tmux/bash configs in new tmux nvim
  windows.
- **tmux** has **no plugins** and **no session-restore plugin** — "restore" in
  the devsetup launchers means *attach-to-existing* via `tmux new-session -A`.
- **neovim** uses **lazy.nvim** (ex-Packer) and the **native `vim.lsp`** API
  (no `nvim-lspconfig`), is **C#/.NET-first** (Roslyn + .NET 10 + netcoredbg
  DAP), and also covers Go / C/C++ / TypeScript + React / Angular / HTML+CSS.
  Leader: `<Space>`.
- **bash** fzf-supplement only (no prompt/aliases/PATH) — kept intentionally
  minimal; `~/.bashrc` remains the system default plus this `source`.