# Neovim Configuration

A personal Neovim setup (`~/.config/nvim`) built around [lazy.nvim](https://github.com/folke/lazy.nvim),
the native `vim.lsp` API, and a focused C# / .NET workflow (with first-class Go, C/C++,
TypeScript, Angular, and web support). The leader key is **`<Space>`**.

---

## Layout

```
init.lua                      -- entry point: leader, treesitter shim, module loading
lua/lbobc/
├── core/
│   ├── options.lua           -- editor options (numbers, indentation, transparency, netrw)
│   ├── keymaps.lua           -- general (non-plugin, non-LSP) key mappings
│   ├── autocmds.lua          -- C# namespace/type autogeneration on new .cs files
│   └── lazy.lua              -- bootstraps lazy.nvim, imports lbobc.plugins
├── plugins/                  -- one file per plugin spec (auto-imported by lazy)
│   ├── lsp.lua               -- Mason + tool installer + loads lbobc.lsp
│   ├── roslyn.lua            -- roslyn.nvim launcher for C#
│   ├── completion.lua        -- nvim-cmp
│   ├── luasnip.lua           -- snippets (C# doc-comment + unit-test templates)
│   ├── treesitter.lua        -- syntax / indentation
│   ├── telescope.lua         -- fuzzy finding + custom C# code search
│   ├── harpoon.lua           -- quick file marks/navigation
│   ├── dap.lua               -- .NET debugging (netcoredbg) + dap-ui
│   ├── conform.lua           -- formatting (format-on-save)
│   ├── autopairs.lua         -- auto-close brackets/quotes
│   └── nvim-rg.lua           -- ripgrep :Rg command
└── lsp/                      -- per-language vim.lsp server configs
    ├── init.lua              -- loads every server config
    ├── shared.lua            -- shared on_attach (LSP keymaps), capabilities, mason_bin()
    ├── csharp.lua            -- roslyn
    ├── c.lua                 -- clangd
    ├── go.lua                -- gopls
    ├── typescript.lua        -- ts_ls (also serves React .jsx/.tsx)
    ├── angular.lua           -- angularls (ngserver)
    └── html.lua              -- html + cssls (CSS/SCSS/LESS)
```

`init.lua` sets `<Space>` as both leader and local-leader **before** lazy loads (so plugin
keymaps register correctly), installs a compatibility shim for the removed
`vim.treesitter.language.ft_to_lang`, then loads the core modules in order.

---

## Plugins

Plugins are managed by **lazy.nvim** (bootstrapped automatically on first launch) and pinned
in `lazy-lock.json`. Each plugin lives in its own spec file under `lua/lbobc/plugins/`.

| Plugin | Purpose | Load trigger |
| --- | --- | --- |
| `folke/lazy.nvim` | Plugin manager | — |
| `mason-org/mason.nvim` | Installs LSP servers, formatters, debuggers | eager (`lazy=false`) |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Auto-installs the listed tools on startup | with mason |
| `seblyng/roslyn.nvim` | Supplies the Roslyn C# language-server `cmd` + init | eager (`lazy=false`) |
| `hrsh7th/nvim-cmp` | Completion engine | `InsertEnter` |
| `hrsh7th/cmp-nvim-lsp` | LSP completion source / capabilities | dependency |
| `hrsh7th/cmp-buffer` | Buffer-word completion source | dependency |
| `hrsh7th/cmp-path` | Filesystem path completion source | dependency |
| `L3MON4D3/LuaSnip` | Snippet engine | `InsertEnter` |
| `saadparwaiz1/cmp_luasnip` | Exposes LuaSnip snippets to nvim-cmp | dependency |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting + indentation | `BufReadPost`, `BufNewFile` |
| `nvim-telescope/telescope.nvim` | Fuzzy finder | `VeryLazy` |
| `nvim-lua/plenary.nvim` | Lua utility library (telescope dep) | dependency |
| `theprimeagen/harpoon` | Mark and jump between key files | `VeryLazy` |
| `mfussenegger/nvim-dap` | Debug Adapter Protocol client | `VeryLazy` |
| `rcarriga/nvim-dap-ui` | Debugger UI | dependency |
| `nvim-neotest/nvim-nio` | Async IO (dap-ui dep) | dependency |
| `theHamsta/nvim-dap-virtual-text` | Inline variable values while stepping | dependency |
| `stevearc/conform.nvim` | Formatter runner (format-on-save) | `VeryLazy` |
| `windwp/nvim-autopairs` | Auto-close brackets and quotes | `InsertEnter` |
| `duane9/nvim-rg` | `:Rg` ripgrep command | on `:Rg` |

### Mason-installed tools

Defined in `plugins/lsp.lua` via `mason-tool-installer` (`run_on_start = true`):

- **LSP servers:** `roslyn`, `clangd`, `gopls`, `typescript-language-server`,
  `angular-language-server`, `html-lsp`, `css-lsp`
- **Formatters:** `csharpier`, `prettierd`, `prettier`
- `clang-format` is expected on `$PATH` (installed via the system package manager, not Mason).
- `netcoredbg` (the .NET debug adapter) is resolved from Mason's install if present, otherwise
  from `$PATH`.

Mason uses two registries: the default `mason-org/mason-registry` plus
`github:Crashdummyy/mason-registry`, which provides the Roslyn server.

---

## Language Servers (LSP)

Configured with the native `vim.lsp.config` / `vim.lsp.enable` API (no `nvim-lspconfig`).
All servers share `on_attach` (the LSP keymaps below) and nvim-cmp completion capabilities
from `lsp/shared.lua`.

| Language | Server | Filetypes | Notes |
| --- | --- | --- | --- |
| C# / .NET | roslyn | `cs` | Inlay hints, full-solution analysis, code-lens references, unimported-namespace completion |
| C / C++ | clangd | `c`, `cpp`, `objc`, `objcpp`, `cuda` | Roots on `compile_commands.json`, `.clangd`, etc. |
| Go | gopls | `go`, `gomod`, `gowork`, `gotmpl` | |
| JS/TS/React | ts_ls | `javascript`, `javascriptreact`, `typescript`, `typescriptreact` | React `.jsx`/`.tsx` = ts_ls + `tsx` treesitter parser |
| Angular | angularls (ngserver) | `typescript`, `html`, `typescriptreact`, `htmlangular` | Probes project `node_modules`, reads `@angular/core` version; roots on `angular.json`/`nx.json` |
| HTML | html | `html`, `htmlangular` | Embedded CSS/JS support |
| CSS | cssls | `css`, `scss`, `less` | Validation enabled |

`shared.lua` also includes a `mason_bin()` helper that resolves a Mason `bin/<tool>` shim to
its realpath, working around the relative-path lookup used by node-based shims.

---

## Treesitter

Parsers ensured on startup (`treesitter.lua`), with highlighting, indentation, and
`auto_install` enabled:

`c_sharp`, `c`, `go`, `python`, `rust`, `lua`, `angular`, `typescript`, `tsx`,
`javascript`, `html`, `css`, `scss`

Pinned to the `master` branch (classic API), since the `main` rewrite changes `setup()`.

---

## Formatting (conform.nvim)

Format-on-save is enabled (500 ms timeout, LSP fallback). It can be disabled per-buffer by
setting `vim.b.disable_autoformat = true`.

| Filetype(s) | Formatter |
| --- | --- |
| `cs` | csharpier |
| `javascript`, `typescript`, `*react`, `html`, `htmlangular`, `css`, `scss`, `less`, `yaml`, `json` | prettierd → prettier |
| `rust` | rustfmt |
| `go` | gofmt |
| `python` | black |
| `c` | clang_format |

---

## Editor Options (`core/options.lua`)

- **Line numbers:** absolute + relative (`number`, `relativenumber`)
- **Indentation:** 4-space, `expandtab`, `smartindent`; `shiftwidth`/`tabstop` = 4
- **Search:** `incsearch` on, `hlsearch` off, `ignorecase` + `smartcase`
- **UI:** `cursorline`, `signcolumn=yes`, `colorcolumn=100`, `termguicolors`, blocky `guicursor`, `scrolloff=8`, no line wrap
- **Splits:** `splitbelow`
- **No swap / no backup files**
- **Transparent background:** `Normal` / `NormalFloat` backgrounds cleared (lets terminal opacity show through)
- **netrw:** tree liststyle, no banner, 25-col width, vertical splits open to the right

---

## Autocommands (`core/autocmds.lua`)

**C# scaffolding on new files** — when a new `*.cs` file is created (`BufNewFile`), the config
derives the namespace from the path after `src/` or `tests/`, then inserts a `namespace …;`
line plus a `public interface`/`public class` declaration (interface if the name starts with
`I` followed by an uppercase letter), and drops you into insert mode inside the body.

---

## Keymaps

Leader is **`<Space>`**.

### General editing (`core/keymaps.lua`)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>e` | n | Open netrw (`Explore`) in current file's directory |
| `J` | v | Move selected lines down |
| `K` | v | Move selected lines up |
| `<leader>\`` | n | Open `$MYVIMRC` in a new tab, `cd` to nvim config, open explorer |
| `<C-c>` | n / v | Copy line / selection to system clipboard (`"+`) |
| `<C-v>` | n / v | Paste from system clipboard |
| `<Esc>` | t | Exit terminal mode |
| `<leader>tt` | n | Open a 10-row terminal split at the bottom |
| `<leader>rr` | n | Find & replace whole word across all `**/*.cs` files (vimgrep + cfdo) |
| `<leader>rf` | n | Find & replace whole word in the current file (with confirm) |
| `<leader>nt` | n | New tab with file explorer |
| `<leader>ct` | n | Close tab, reopen explorer |
| `<leader>tb` | n | Toggle background dark/light |

### LSP (set per-buffer on attach — `lsp/shared.lua`)

| Key | Action |
| --- | --- |
| `<leader>gd` | Go to definition |
| `<leader>fr` | Find references |
| `<leader>gi` | Go to implementation |
| `<leader>D` | Type definition |
| `<leader>dd` | Hover documentation |
| `<leader>se` | Show diagnostic in float |
| `<S-j>` | Next diagnostic (with float) |
| `<S-k>` | Previous diagnostic (with float) |

### Telescope (`plugins/telescope.lua`)

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Find git-tracked files |
| `<leader>fs` | Grep with prompted search string |
| `<leader>fw` | Grep the word under the cursor (project-wide, every occurrence) |
| `<leader>gc` | Find the C# **class/enum/interface/record declaration** of the word under cursor (regex) |
| `<leader>gm` | Find the C# **method declaration** of the word under cursor (regex) |

### Harpoon (`plugins/harpoon.lua`)

| Key | Action |
| --- | --- |
| `<leader>af` | Add current file to harpoon |
| `<leader>sf` | Toggle the harpoon quick menu |
| `<leader>1` … `<leader>5` | Jump to harpoon file 1–5 |

### Completion — nvim-cmp (insert mode, `plugins/completion.lua`)

| Key | Action |
| --- | --- |
| `<Tab>` | Confirm the selected completion item |
| `<C-j>` | Next item |
| `<C-k>` | Previous item |

Sources, in priority order: LSP (`nvim_lsp`) and snippets (`luasnip`), then current-buffer
words (`buffer`). The keyword pattern is extended to include `/`.

### Snippets — LuaSnip (insert/select mode, `plugins/luasnip.lua`)

| Key | Action |
| --- | --- |
| `<Tab>` | Expand snippet / jump to next placeholder |
| `<S-Tab>` | Jump to previous placeholder |

C# snippet triggers:

- `/ccd/` — class `<summary>` doc comment
- `/cld/` — class `<summary>` starting "Represents …"
- `/cd/` — constructor `<summary>` with `<see cref>`
- `/md/` — method doc block (`<summary>`, four `<param>`, `<exception>`, `<returns>`)
- `/utaaa/` — unit-test Arrange/Act/Assert skeleton

### Debugging — nvim-dap (`plugins/dap.lua`)

Configured for .NET via **netcoredbg**. On launch you're prompted for the `.dll`
(remembered across runs); `cwd` defaults to the dll's directory and `ASPNETCORE_ENVIRONMENT`/
`DOTNET_ENVIRONMENT` are set to `Development`. An attach-to-process config is also registered.
The dap-ui opens automatically when a session starts and closes when it ends. Configs apply to
`cs`, `fsharp`, and `vb` filetypes.

| Key | Action |
| --- | --- |
| `<leader>db` / `<leader>dc` | Continue / start |
| `<leader>dn` | Step over (next) |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>bp` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint (prompts for condition) |
| `<leader>lp` | Log point (prompts for message) |
| `<leader>dr` | Open the DAP REPL |
| `<leader>dl` | Run last configuration |
| `<leader>dt` | Stop (detach if attached, terminate if launched) |
| `<leader>du` | Toggle the dap-ui |
| `<leader>de` | Evaluate expression in a float |

Custom breakpoint/stopped signs use ASCII-friendly glyphs (`●`, `◆`, `◉`, `▶`, `✖`) with
dedicated highlight groups so they render without a Nerd Font.

---

## Notable design choices

- **Native LSP API, no `nvim-lspconfig`** — each server is configured directly with
  `vim.lsp.config` + `vim.lsp.enable`, sharing keymaps/capabilities through `lsp/shared.lua`.
- **C#-centric workflow** — Roslyn settings tuned for full-solution analysis, custom Telescope
  searches for C# declarations, doc-comment snippets, `.cs` scaffolding autocmd, and a .NET
  debug setup.
- **Eager loading where ordering matters** — mason and roslyn.nvim load with `lazy=false` so
  the Roslyn `cmd` and `vim.lsp.enable()` FileType triggers register before the first `.cs`
  buffer opens.
- **Transparent background** for terminal opacity (e.g. Alacritty).
</content>
</invoke>
