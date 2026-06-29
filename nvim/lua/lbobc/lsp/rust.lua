-- Rust — rust-analyzer
local s = require("lbobc.lsp.shared")

vim.lsp.config("rust_analyzer", {
  cmd = { s.mason_bin("rust-analyzer") },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  on_attach = s.on_attach,
  capabilities = s.capabilities,
})
vim.lsp.enable("rust_analyzer")