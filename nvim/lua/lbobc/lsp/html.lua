-- HTML + CSS/SCSS/LESS — vscode-html-language-server / vscode-css-language-server
local s = require("lbobc.lsp.shared")

-- HTML (templates)
vim.lsp.config("html", {
  cmd = { s.mason_bin("vscode-html-language-server"), "--stdio" },
  filetypes = { "html", "htmlangular" },
  root_markers = { "package.json", ".git" },
  init_options = {
    provideFormatter = true,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { "html", "css", "javascript" },
  },
  on_attach = s.on_attach,
  capabilities = s.capabilities,
})
vim.lsp.enable("html")

-- CSS / SCSS / LESS
vim.lsp.config("cssls", {
  cmd = { s.mason_bin("vscode-css-language-server"), "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
  on_attach = s.on_attach,
  capabilities = s.capabilities,
})
vim.lsp.enable("cssls")
