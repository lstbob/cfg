-- Load every per-language LSP server config. Each module pulls shared
-- on_attach / capabilities / helpers from lua/lbobc/lsp/shared.lua.
require("lbobc.lsp.csharp")
require("lbobc.lsp.c")
require("lbobc.lsp.go")
require("lbobc.lsp.rust")
require("lbobc.lsp.typescript")
require("lbobc.lsp.angular")
require("lbobc.lsp.html")
