-- Go — gopls
local s = require("lbobc.lsp.shared")

vim.lsp.config("gopls", {
  cmd = { s.mason_bin("gopls") },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  on_attach = s.on_attach,
  capabilities = s.capabilities,
})
vim.lsp.enable("gopls")
