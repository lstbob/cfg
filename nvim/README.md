# Neovim configuration

## Summary

A Neovim configuration focused on **C# / .NET** development, with first-class support
for **C, Go, Rust, JavaScript/TypeScript, React, Angular and HTML/CSS**. Plugins are managed
by [**lazy.nvim**](https://github.com/folke/lazy.nvim) and LSP is wired through Neovim's
native `vim.lsp` API (no `nvim-lspconfig` needed).

Tested on **Debian 13 (trixie)** with **Neovim 0.12**. Anything on **Neovim ≥ 0.11**
should work (the config uses `vim.lsp.config` / `vim.lsp.enable` and `vim.diagnostic.jump`,
which require 0.11+).

## Structure

```
nvim/
├── init.lua                  # leader, a small compat shim, loads core/*, bootstraps lazy
├── lazy-lock.json            # pinned plugin versions (keeps machines in sync)
└── lua/lbobc/
    ├── core/
    │   ├── options.lua       # vim options + transparent background
    │   ├── keymaps.lua       # general key mappings (explore, move lines, find/replace, tabs…)
    │   ├── autocmds.lua      # C# namespace + type autogeneration for new .cs files
    │   └── lazy.lua          # lazy.nvim bootstrap + setup{ import = "lbobc.plugins" }
    ├── plugins/              # one lazy spec per plugin/concern
    │   ├── telescope.lua  treesitter.lua  harpoon.lua  completion.lua  luasnip.lua
    │   ├── conform.lua     dap.lua         autopairs.lua  nvim-rg.lua
    │   ├── lsp.lua          # mason + mason-tool-installer; loads lua/lbobc/lsp
    │   └── roslyn.lua        # the C# (Roslyn) launcher
    └── lsp/                  # per-language server configs (native vim.lsp API)
        ├── init.lua          # requires every language module below
        ├── shared.lua        # on_attach keymaps, cmp capabilities, mason_bin() helper
        ├── csharp.lua        # roslyn
        ├── c.lua             # clangd
        ├── go.lua            # gopls
        ├── rust.lua          # rust_analyzer
        ├── typescript.lua    # ts_ls — JavaScript, TypeScript and React (.jsx/.tsx)
        ├── angular.lua       # angularls (ngserver)
        └── html.lua          # html + cssls (HTML / CSS / SCSS / LESS)
```

> **React** has no dedicated language server: `.jsx`/`.tsx` are served by `ts_ls`
> (`typescript.lua`) and highlighted by the `tsx` Treesitter parser.

## Requirements (host toolchains)

lazy.nvim installs the *plugins*, and Mason installs the *language servers/formatters* —
but several of those build against tools that must already be on the host:

| Tool                    | Needed for                                              |
| ----------------------- | ------------------------------------------------------- |
| **Neovim ≥ 0.11**       | the config itself                                       |
| **git**                 | lazy.nvim bootstrap + plugin installs                   |
| **A C/C++ compiler** (`build-essential`) | compiling Treesitter parsers           |
| **ripgrep**             | Telescope live grep / fuzzy find                        |
| **.NET 10 SDK**         | Roslyn (the C# server now targets .NET 10)              |
| **Node.js + npm**       | ts_ls, angularls, html/css servers, prettier(d)         |
| **Go toolchain**        | building/running `gopls`                                |
| **clang + clang-format**| C language server + C formatting                        |
| **rustup** (rust-analyzer, rustfmt) | Rust language server + Rust formatting       |
| **python3**             | some Mason packages                                     |

## Installation (Debian / Linux)

1. **Neovim.** The version in apt is usually too old. Download the latest stable tarball
   (preferred over the AppImage, which needs FUSE) and put it on `PATH`:
   ```bash
   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
   sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
   sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
   ```

2. **Base tools.**
   ```bash
   sudo apt-get update
   sudo apt-get install -y git build-essential ripgrep nodejs npm python3 \
                           golang-go clang clang-format xsel
   ```

3. **.NET 10 SDK** (Roslyn requires it). Add the Microsoft repo and install:
   ```bash
   curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
     | sudo gpg --dearmor --yes -o /usr/share/keyrings/microsoft-prod.gpg
   # (repo deb already configured under /etc/apt/sources.list.d/microsoft-prod.list)
   sudo apt-get update
   sudo apt-get install -y dotnet-sdk-10.0
   ```
   See Microsoft's [Debian install guide](https://learn.microsoft.com/en-us/dotnet/core/install/linux-debian)
   if the repo isn't set up yet.

4. **Clone this repo and link the nvim folder** into place:
   ```bash
   git clone git@github.com:lstbob/cfg.git ~/dev/cfg
   ln -s ~/dev/cfg/nvim ~/.config/nvim
   ```

5. **First launch.** Just open Neovim:
   ```bash
   nvim
   ```
   - lazy.nvim bootstraps itself and installs every plugin.
- `mason-tool-installer` auto-installs the servers/formatters on startup:
      `roslyn`, `clangd`, `gopls`, `rust-analyzer`, `typescript-language-server`,
      `angular-language-server`, `html-lsp`, `css-lsp`, `csharpier`, `prettierd`, `prettier`.
   - Treesitter compiles its parsers (needs the C compiler from step 2).

   Watch progress with `:Lazy` and `:Mason`. Give it a minute on the first run.

6. **Verify.** Open a `.cs` file inside a project (one with a `.csproj`/`.sln`) — Roslyn
   attaches after the solution loads. `:checkhealth` and `:Mason` should be clean.

## Running the same config under WSL (Windows)

The config is identical on WSL — you just need the Linux toolchain inside the distro.

1. **Install WSL + a distro** (PowerShell as Administrator), then reboot:
   ```powershell
   wsl --install -d Debian
   ```
   Launch "Debian" from the Start menu and create your user.

2. **Inside the WSL shell**, run the **same steps 1–5 above** (Neovim tarball, base tools,
   .NET 10 SDK, clone + symlink, first launch). They are plain Debian steps and work as-is.

3. **Clipboard integration.** WSL has no native X clipboard, so `"+y` / `"+p` (used by this
   config's copy/paste maps) need a bridge. Install **win32yank**, which Neovim auto-detects
   on WSL:
   ```bash
   curl -fsSLO https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
   unzip win32yank-x64.zip win32yank.exe
   sudo install win32yank.exe /usr/local/bin/
   rm win32yank-x64.zip win32yank.exe
   ```
   (`xsel` from step 2 is the native-Linux equivalent and isn't needed under WSL.)

4. **Editing files.** Keep your code **inside the WSL filesystem** (e.g. `~/dev/...`), not
   under `/mnt/c/...` — LSP file-watching and Treesitter are much faster on the native FS.

5. **Keeping both machines in sync.** `lazy-lock.json` is committed, so plugin versions
   match across your Linux box and WSL. After pulling changes, run `:Lazy restore` to pin
   plugins to the lockfile.

## Formatters (conform.nvim)

Formatting is handled by [conform.nvim](https://github.com/stevearc/conform.nvim) with
format-on-save (`<leader>f` to format manually). Most formatters are installed by Mason;
the rest come from the host toolchain:

| Language                    | Formatter   | How it's provided                                  |
| --------------------------- | ----------- | -------------------------------------------------- |
| C#                          | csharpier   | Mason (`mason-tool-installer`)                     |
| JS / TS / JSON / YAML / CSS / HTML | prettierd → prettier | Mason                                  |
| C / C++                     | clang-format| host: `sudo apt install clang-format`              |
| Go                          | gofmt       | ships with the Go toolchain                        |
| Rust                        | rustfmt     | `rustup component add rustfmt`                     |
| Python                      | black       | `pipx install black` (or your preferred method)    |

## Troubleshooting

- **`apt-get update` fails with "SHA1 is not considered secure"** (Debian 13/trixie only):
  the repo's signing key is SHA-1 and trixie's verifier rejects it. Refresh the key, e.g.
  for Microsoft: `curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor --yes -o /usr/share/keyrings/microsoft-prod.gpg`.
  Debian 12 (bookworm) is unaffected.

- **Roslyn won't start / "Failed to get language"**: ensure the **.NET 10** runtime is
  installed and is what `dotnet` resolves to. The Roslyn server is a .NET *apphost* — it
  finds its runtime via `DOTNET_ROOT` / the system install (`/usr/share/dotnet`), **not**
  `PATH`. Installing `dotnet-sdk-10.0` system-wide is the simplest fix.

- **Treesitter `tree-sitter-<lang>-tmp ... File exists`**: a compile was interrupted. Clean
  the stale dirs and reinstall:
  ```bash
  rm -rf ~/.local/share/nvim/tree-sitter-*-tmp
  ```
  then `:TSInstallSync <lang>` (or `:TSUpdate`).

- **A server isn't installed**: `:Mason` shows status; gopls needs Go on the host,
  clang-format is installed via apt (Mason's PyPI route needs pip).
