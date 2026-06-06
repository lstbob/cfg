-- Roslyn launcher. Plain vim.lsp.config("roslyn", …) only carries *settings*;
-- this plugin supplies the actual `cmd` (the mason-installed roslyn-language-server)
-- and the custom initialization Roslyn needs, then enables it. The C# server
-- settings live in lua/lbobc/lsp/csharp.lua (merged in via vim.lsp.config).
--
-- Loaded eagerly (lazy=false) so the roslyn cmd is registered before the first
-- .cs buffer opens, avoiding a race with the LSP FileType trigger.
return {
  "seblyng/roslyn.nvim",
  lazy = false,
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {},
}
