-- Leader must be set before lazy.nvim loads so plugin keymaps register correctly.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Compat shim: some plugins still call the removed vim.treesitter.language.ft_to_lang.
if vim.treesitter.language.ft_to_lang == nil then
  vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
end

require("lbobc.core.options")
require("lbobc.core.keymaps")
require("lbobc.core.autocmds")
require("lbobc.core.lazy")

print("Happy coding :* ")
