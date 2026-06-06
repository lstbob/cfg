-- JavaScript / TypeScript / React — typescript-language-server (ts_ls)
--
-- React note: there is no dedicated React language server. React `.jsx`/`.tsx`
-- files are served here by ts_ls (via the *react filetypes below) for LSP, and
-- highlighted by the `tsx` Treesitter parser. So "React" = ts_ls + treesitter,
-- not a separate config file.
local s = require("lbobc.lsp.shared")

vim.lsp.config("ts_ls", {
  cmd = { s.mason_bin("typescript-language-server"), "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json" },
  on_attach = s.on_attach,
  capabilities = s.capabilities,
})
vim.lsp.enable("ts_ls")
