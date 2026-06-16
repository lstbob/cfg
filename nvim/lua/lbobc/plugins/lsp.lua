-- Mason installs the LSP servers / tools and then loads the per-language
-- server configs in lua/lbobc/lsp/. Kept eager (lazy=false) so vim.lsp.enable()
-- registers its FileType triggers at startup; cmp-nvim-lsp is a dependency so
-- completion capabilities are available when the configs are built.
return {
  "mason-org/mason.nvim",
  lazy = false,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup({
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry", -- provides roslyn
      },
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        -- LSP servers
        "roslyn",
        "clangd",
        "gopls",
        "typescript-language-server",
        "angular-language-server",
        "html-lsp",
        "css-lsp",
        -- Formatters
        "csharpier",
        "prettierd",
        "prettier",
        "goimports", -- Go formatter that also adds/removes imports (replaces gofmt)
        -- clang-format: installed via the system package manager (Mason's PyPI
        -- route needs pip, which isn't present); conform finds it on $PATH.
      },
      run_on_start = true,
      auto_update = false,
    })

    -- Define + enable every language server (lua/lbobc/lsp/init.lua)
    require("lbobc.lsp")
  end,
}
