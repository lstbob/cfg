-- C / C++ — clangd
local s = require("lbobc.lsp.shared")

vim.lsp.config("clangd", {
  cmd = { s.mason_bin("clangd") },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    ".clangd",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
  },
  on_attach = s.on_attach,
  capabilities = s.capabilities,
})
vim.lsp.enable("clangd")
