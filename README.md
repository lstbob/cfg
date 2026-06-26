# cfg — personal dotfiles

Config files for my dev environment, intentionally portable across **two
machines that share Debian Trixie**:

- **Native** — Debian Trixie, GNOME/Wayland. Alacritty runs as a native
  Linux app; two GNOME Dash launchers open persistent `tmux` sessions.
- **Windows 11 + WSL** — Debian Trixie inside WSL; Alacritty runs as a
  Windows app and shells into WSL via `wsl -d debian -- bash -lc`.

One installer wires everything on either machine: **`setup.sh`** at the repo
root. Run it inside Debian bash; it detects WSL vs native and branches only
where the OS differs.

## Layout

| Path              | What it is                                              | Docs                          |
|-------------------|---------------------------------------------------------|-------------------------------|
| `setup.sh`        | **Unified installer** for both OSes (detects WSL)       | (header of the script)        |
| `alacritty/`      | Active terminal: `base.toml` + `bindings-{linux,wsl}.toml` + vendored themes (~230) | see below |
| `bin/`            | Helper scripts: `open-alacritty-config.sh`, `rose-pine-toggle.sh` | — |
| `bash/`           | fzf **supplement** (not a full bashrc)                 | —                             |
| `tmux/`           | `tmux.conf`: prefix `Alt+Space`, truecolor, transparent bg, **tmux-resurrect + tmux-rose-pine plugins**, OS-aware clipboard | — |
| `nvim/`           | Neovim config: lazy.nvim, native `vim.lsp`, C#/.NET-first, **rose-pine** colorscheme | [`nvim/README.md`](nvim/README.md), [`nvim/SETUP.md`](nvim/SETUP.md) |
| `kitty/`          | Legacy/optional terminal (superseded by alacritty)     | —                             |
| `devsetup/`       | Alacritty Dash launchers for `dev` + `opencode` tmux sessions (native Linux only) | [`devsetup/README.md`](devsetup/README.md) |
| `git.txt`         | Personal SSH/git cheat-sheet (not a deployed config)   | —                             |

## Prerequisites (install manually first)

`setup.sh` **does not apt-install**; it checks and fails fast if anything's missing.

```bash
sudo apt install -y tmux ripgrep fzf build-essential git curl xclip
# Alacritty:   cargo install alacritty          (native Linux)
#              winget install Alacritty.Alacritty (Windows, for the WSL box)
# opencode:    curl -fsSL https://opencode.ai/install | bash
# Neovim >=0.11 (upstream tarball; apt on trixie is too old)
git clone git@github.com:lstbob/cfg <CFG_DIR>     # /mnt/data/dev/cfg | ~/dev/cfg
```

## Quick setup (either machine)

```bash
cd <CFG_DIR>
./setup.sh
```

What it does (OS-branching only where needed):
- clones tmux plugins → `~/.local/share/tmux/plugins/{tmux-resurrect,tmux-rose-pine}`
- symlinks Debian-side configs into the repo: `~/.config/nvim`, `~/.tmux.conf`, and a `source` line in `~/.bashrc`
- wires Alacritty:
  - native Linux → **symlinks** `base.toml` + `bindings-linux.toml` + `themes` into the repo
  - WSL → **copies** `base.toml` + `bindings-wsl.toml` + theme files to `%APPDATA%\alacritty` (Windows Alacritty can't follow Linux symlinks)
- generates the tiny top-level `alacritty.toml` (imports base + OS bindings + `rose_pine.toml`)
- bootstraps nvim plugins (`nvim --headless +Lazy!sync`)
- native Linux only: runs `devsetup/install.sh` (GNOME Dash launchers)
- prints remaining manual steps (restart Alacritty / `tmux source-file` / pin to Dash)

## How the Alacritty config is split (no more two-file drift)

Two fully-duplicated alacritty configs drift easily. Instead this repo uses
three files + a generated entry point (Alacritty `import` merges in order; arrays replace):

- `alacritty/base.toml` — shared (cursor, `startup_mode="Fullscreen"`, `opacity=0.85`). **No** `[keyboard]`, **no** theme import — so it never conflicts and never goes stale.
- `alacritty/bindings-linux.toml` — `[keyboard]` using `bash -lc "…"`.
- `alacritty/bindings-wsl.toml` — `[keyboard]` using `wsl -d debian -- bash -lc "…"`.
- the generated `alacritty.toml` — just `[general] import = [base, OS bindings, rose_pine.toml]`. Edit the live theme by editing one import line (or use `bin/rose-pine-toggle.sh`, bound to Ctrl+Shift+B).

## Notable design choices

- **Alacritty** fullscreen + 0.85 opacity, **rose-pine**; config-edit hotkeys (`Ctrl+,` / `.` / `/`) open the alacritty/tmux/bash configs in new tmux nvim windows via `bin/open-alacritty-config.sh` (OS-aware).
- **tmux** uses **tmux-resurrect** (cross-reboot session restore) + **tmux-rose-pine** status bar; truecolor passthrough; transparent window bg; clipboard is OS-aware (`clip.exe` on WSL, `xclip` on Linux) via one `if-shell`.
- **neovim** uses **lazy.nvim** (ex-Packer) and the **native `vim.lsp`** API (no `nvim-lspconfig`), is **C#/.NET-first** (Roslyn + .NET 10 + netcoredbg DAP), and also covers Go / C/C++ / TypeScript + React / Angular / HTML+CSS. Leader: `<Space>`. Adds **telescope-fzf-native** (fzf operators `^ $ ' !` in finders) + `<leader>fS` glob grep — see [`nvim/SEARCH.md`](nvim/SEARCH.md).
- **bash** fzf-supplement only (no prompt/aliases/PATH) — kept intentionally minimal; `~/.bashrc` remains the system default plus this `source`.

See [`devsetup/README.md`](devsetup/README.md) for the Dash-launcher details
and [`nvim/README.md`](nvim/README.md) for the editor's dependencies
(.NET 10 SDK, Go, clang, Node.js, …).