# devsetup — Alacritty dash launchers for tmux sessions

Two GNOME Dash launchers that open **Alacritty** at `/mnt/data/dev`,
each attached to (or creating) its own persistent **tmux** session.

| Launcher             | tmux session | Icon          | Purpose                                  |
|----------------------|--------------|---------------|------------------------------------------|
| `Dev (tmux)`         | `dev`        | neovim        | Dev windows: front-end, back-end, devops, bash, … |
| `Opencode (tmux)`    | `opencode`   | opencode logo | Opencode sessions/prompts                |

`tmux new-session -A -s <name>` **attaches** to the session if it exists,
otherwise **creates** it. After reboots, `tmux-resurrect` (now in `tmux/.tmux.conf`)
can restore saved windows/panes; clicking the pinned icon then reattaches.

---

## Prerequisites

- **Debian Trixie** (Debian 13), **GNOME on Wayland**
- **Alacritty 0.17+** at `~/.cargo/bin/alacritty` (supports `--class`,
  `--working-directory`, `-e`)
- **tmux 3.x** (`sudo apt install tmux`)
- **opencode** at `~/.opencode/bin/opencode`
- **neovim** installed (`sudo apt install neovim`) — needed so the `dev`
  launcher can reuse its icon at `/usr/share/icons/hicolor/128x128/apps/nvim.png`
- **`/mnt/data/dev` exists** — this is where both sessions `cd` into; this cfg
  repo is expected to be cloned at `/mnt/data/dev/cfg`

---

## Files in this folder

| File                          | What it is                                             |
|-------------------------------|--------------------------------------------------------|
| `alacritty-dev.desktop`       | Dash entry → Alacritty → `/mnt/data/dev` → tmux `dev` |
| `alacritty-opencode.desktop`  | Dash entry → Alacritty → `/mnt/data/dev` → tmux `opencode` |
| `install.sh`                  | Idempotent installer for both desktop files + icons    |
| `README.md`                   | This file                                              |

> The opencode logo icon is **not** shipped; `install.sh` downloads it from
> `https://opencode.ai/apple-touch-icon-v3.png` at install time (per the user's
> preference). Re-run `install.sh` if the URL ever changes.

---

## Quick start

```bash
cd /mnt/data/dev/cfg/devsetup
./install.sh
```

Then:

1. Open **Activities** (Super), search **"Dev (tmux)"**, launch it once.
2. Right-click its running icon → **Pin to Dash**.
3. Repeat for **"Opencode (tmux)"**.

Verify:

```bash
tmux ls        # -> dev: ..., opencode: ...
```

Clicking a pinned icon a second time should **attach** to the existing session
(same windows count), not create `dev-2` / `opencode-2`.

---

## How it works

Each `.desktop` file launches alacritty with three key flags:

```
alacritty --class alacritty-dev --title Dev \
  --working-directory /mnt/data/dev \
  -e tmux new-session -A -s dev
```

- **`--class alacritty-dev`** sets the Wayland **app_id**.
- **`StartupWMClass=alacritty-dev`** (in the `.desktop`) tells GNOME to match
  the running window to this exact icon. Without it, both launchers would
  **merge** into a single generic "Alacritty" dash icon.
- **`--working-directory /mnt/data/dev`** is used instead of
  `bash -c "cd ... && tmux ..."` — desktop-file `Exec=` parsing forbids
  unescaped `&&` and quotes, and that pattern produces the error
  *"Desktop file didn't specify Exec field"*. Using Alacritty's native flag
  avoids all shell metacharacters.
- **`-e tmux new-session -A -s <name>`** = attach-or-create the named session.
- **Fullscreen** comes from the default `~/.config/alacritty/alacritty.toml`
  (`startup_mode = "Fullscreen"`). No per-launcher override is passed; both
  launchers open fullscreen.

---

## Pin to Dash

GNOME doesn't expose "pin" for arbitrary `.desktop` files directly; the
workflow is:

1. Install the files (`./install.sh`).
2. Open Activities, launch each app once (they must actually run so a window
   icon appears).
3. Right-click the running icon on the dash → **Pin to Dash**.

Pinned icons persist across logins. Because each has a unique
`StartupWMClass`, GNOME keeps them as **two separate** pinned entries.

---

## Related configs in this repo

The alacritty config-edit hotkeys (see `alacritty/bindings-linux.toml`) shell out
to `tmux` + `nvim`, so the **alacritty / tmux / nvim** configs must all be in
place for those shortcuts to work. The repo's root `setup.sh` wires all of
them (symlinks on native Linux / copies for the Windows Alacritty bits on WSL).
`devsetup/install.sh` only handles the two GNOME Dash launchers.

### `alacritty/` — active terminal (split config)

Setup is done by `setup.sh`; it symlinks (native Linux) or copies (WSL) the
three files below and generates the tiny top-level `alacritty.toml`:

```bash
# what setup.sh effectively does on native Linux:
ln -sfn <CFG_DIR>/alacritty/base.toml          ~/.config/alacritty/base.toml
ln -sfn <CFG_DIR>/alacritty/bindings-linux.toml ~/.config/alacritty/bindings-linux.toml
ln -sfn <CFG_DIR>/alacritty/themes             ~/.config/alacritty/themes
# generates ~/.config/alacritty/alacritty.toml  -> imports the three above
```

- `base.toml` — shared (no `[keyboard]`, no theme): `startup_mode="Fullscreen"`, `opacity=0.85`, Block cursor, always-blink.
- `bindings-{linux,wsl}.toml` — OS-specific `[keyboard]` (bash on Linux, `wsl -d debian` on Windows).
- Theme: **rose-pine** (`themes/themes/rose_pine.toml`); switch by editing the single `import` line in the generated `alacritty.toml`. (`bin/rose-pine-toggle.sh` exists in the repo as an optional helper but is no longer installed by `setup.sh`.)
- Hotkeys: `F11` toggle fullscreen, `F10` minimize,
  `Ctrl+,` edit `alacritty.toml` (new tmux window, via `bin/open-alacritty-config.sh`), `Ctrl+.` edit `.tmux.conf`,
  `Ctrl+/` edit `.bashrc`, `Ctrl+Home` send `cd ~`, `Ctrl+End` send `cd /`.

### `tmux/` — plugins + rose-pine status bar

`setup.sh` symlinks `~/.tmux.conf` to `tmux/.tmux.conf` and clones the plugins
to `~/.local/share/tmux/plugins/{tmux-resurrect,tmux-rose-pine}`.

- **Prefix remapped to `Alt+Space`** (default `Ctrl-b` is unbound).
- `mouse on`, `base-index`/`pane-base-index` = 1, `mode-keys vi`.
- Truecolor passthrough (`tmux-256color` + `terminal-features ",*:RGB"`) so Neovim/rose-pine renders its full palette.
- Transparent window bg; **tmux-rose-pine** status bar (variant `main`).
- **tmux-resurrect** is now included for cross-reboot session restore. "Restore" in these devsetup launchers means both *attach-to-existing* after a window close (`tmux new-session -A`) **and** full window/pane restore across a reboot via resurrect.

### `bash/` — fzf **supplement** (not a standalone bashrc)

`bash/.bashrc` is only the user's fzf additions (~11 lines). It is **not** a
full shell config — append or `source` it from your real `~/.bashrc`:

```bash
# in ~/.bashrc, near the end:
[ -f /mnt/data/dev/cfg/bash/.bashrc ] && source /mnt/data/dev/cfg/bash/.bashrc
```

Adds: `eval "$(fzf --bash)"`, a `FZF_CTRL_T_OPTS` file/dir preview, and a
`Ctrl-F` readline binding that runs fzf (with `bat` preview) to pick a file
and open it in `nvim`. No `PS1`, no aliases, no `PATH` changes.

### `nvim/` — flagship, well-documented (separate READMEs)

```bash
ln -sfn /mnt/data/dev/cfg/nvim ~/.config/nvim
```

See **`nvim/README.md`** (install guide, Debian + WSL) and **`nvim/SETUP.md`**
(full plugin/keymap/LSP reference) for the complete story. In short:

- Requires **Neovim ≥ 0.11** (uses native `vim.lsp.config`/`enable`).
- Plugin manager: **lazy.nvim** (auto-bootstraps; migrated from Packer).
  20 plugins, versions pinned in `lazy-lock.json`.
- **LSP via native `vim.lsp`** (no `nvim-lspconfig`). Servers: **C#/.NET
  Roslyn** (primary, `.NET 10 SDK` + `netcoredbg` DAP), Go (`gopls`,
  `goimports`), C/C++ (`clangd`), TS/JS/React (`ts_ls`), Angular
  (`angularls`), HTML/CSS (`html`/`cssls`). Mason installs tools on startup.
- **Leader: `<Space>`.**
- Format-on-save via `conform.nvim` (per-language: csharpier, prettier,
  goimports, rustfmt, black, clang_format).
- C# scaffolding autocmd: new `.cs` files get a derived `namespace` + class
  skeleton.

Dependencies on the host: `build-essential`, ripgrep, Node.js + npm, .NET 10
SDK, Go toolchain, clang + clang-format, python3. See `nvim/README.md` for the
exact Debian install commands and known trixie pitfalls.

### `kitty/` — legacy/optional (superseded by alacritty)

Present in the repo for reference but **not actively used**. The config has
a corrupted line and broken `--map` theme-switch bindings. Skip unless you
specifically want kitty; Alacritty is the active terminal.

```bash
# only if you really want kitty:
mkdir -p ~/.config/kitty
ln -sf /mnt/data/dev/cfg/kitty/kitty.conf ~/.config/kitty/kitty.conf
```

### `git.txt` — personal cheat-sheet (not a deployed config)

SSH key setup + `core.editor=vim` reminders. Reference only; nothing to link.

---

## Reproduction on a fresh Debian Trixie machine

[EITHER machine is "fresh" — native Linux OR WSL Debian.]

- **Install base tools**:
  ```bash
  sudo apt update
  sudo apt install -y tmux ripgrep fzf build-essential git curl xclip neovim
  ```

  **Manual installs** (these depend on the box; `sudo apt install --no-install-recommends neovim` on trixie is too old — install the upstream tarball):

  ```bash
  # Alacritty  >= 0.17 (supports --class on Wayland):
  #   native Linux : cargo install alacritty            # -> ~/.cargo/bin/alacritty
  #   WSL         : winget install Alacritty.Alacritty  # (run in Windows PowerShell)
  # opencode:
  curl -fsSL https://opencode.ai/install | bash
  # Neovim >= 0.11 (tarball from github.com/neovim/neovim/releases)
  ```

- **Install the language toolchains** nvim expects (see [`nvim/README.md`](../nvim/README.md)):

  Node.js + npm, .NET 10 SDK, Go, clang + clang-format, python3.

- **Clone this repo**:
  ```bash
  # native Linux:
  sudo mkdir -p /mnt/data/dev && sudo chown "$USER:" /mnt/data/dev
  git clone git@github.com:lstbob/cfg /mnt/data/dev/cfg
  # WSL:
  git clone git@github.com:lstbob/cfg ~/dev/cfg
  ```

- **Run the unified installer** from inside the repo. `setup.sh` detects WSL vs native Linux and wires everything: symlinks nvim/tmux/bash into the repo, sets up alacritty (symlink on Linux / copy to `%APPDATA%` on WSL), clones tmux plugins, installs `open-alacritty-config.sh`, bootstraps nvim plugins, and (native Linux only) runs `devsetup/install.sh`:
  ```bash
  cd <CFG_DIR>            # /mnt/data/dev/cfg | ~/dev/cfg
  ./setup.sh
  ```

- **Native Linux only — pin to Dash**: launch "Dev (tmux)" and "Opencode (tmux)" once each from
  Activities, right-click → **Pin to Dash**.

- **Verify**:
  ```bash
  tmux ls                          # dev: ..., opencode: ...
  tmux show -g prefix              # M-Space
  tmux show -g @rose_pine_variant  # main
  nvim -c ':colorscheme' +qa       # rose-pine
  readlink ~/.config/nvim ~/.tmux.conf   # -> points into the cfg repo
  ```

---

## Troubleshooting

- **"Desktop file didn't specify Exec field"** — happens if `Exec=` contains
  unescaped shell metacharacters (`&&`, `'`, `"`, `(`, `)`, `<`, `>`, `~`,
  `|`, `;`, `*`, `?`, `&`). The fix used here is to **avoid `bash -c
  "cd ... && tmux ..."`** and instead use Alacritty's native
  `--working-directory` flag, leaving `Exec=` with only plain arguments.
  Validate with `desktop-file-validate <file>`.

- **Icons don't render / show generic gear** — run
  `gtk-update-icon-cache -f ~/.local/share/icons/hicolor`, or log out/in.
  `gtk-update-icon-cache` may warn *"No theme index file"* on the user path;
  that's harmless, GNOME finds user-hicolor icons via XDG fallback.

- **Both launchers merge into one Dash icon** — your `--class` and
  `StartupWMClass` don't match (case-sensitive). Verify the running window's
  app_id with Wayland introspection; it must equal the `.desktop`'s
  `StartupWMClass`.

- **Second click opens a brand-new window instead of attaching** — you're
  not using `tmux new-session -A` (the `-A` is what attaches-or-creates).
  Check the `Exec=` line and `tmux ls`.

- **Launches windowed, not fullscreen** — the default
  `~/.config/alacritty/alacritty.toml` sets `startup_mode = "Fullscreen"`.
  Either that file isn't symlinked/installed, or it was edited. Per-launcher
  override is possible with `-o window.startup_mode="Windowed"`.

- **opencode icon download fails** — `install.sh` will warn but continue;
  the launcher will have no icon until you manually place a PNG at
  `~/.local/share/icons/hicolor/256x256/apps/alacritty-opencode.png`.
  Re-run `install.sh` once you have network.