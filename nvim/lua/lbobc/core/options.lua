-- General editor options
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.scrolloff = 8
vim.opt.splitbelow = true
vim.opt.shellxquote = ""
vim.opt.cursorline = true
vim.opt.guicursor = ""
vim.opt.termguicolors = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.wo.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.cmd([[set colorcolumn=100]])
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.wrap = false
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0  -- Hide help banner
vim.g.netrw_winsize = 25 -- Set window width
vim.g.netrw_altv = 1    -- Vertical splits to the right
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- transparent background (lets Alacritty opacity show through)
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- Dim-grey selection backgrounds so highlighted regions stay visible; the
-- shade tracks the cfg theme (dark soft-gray vs Solarized Light). Read the
-- shared state file so a fresh nvim matches whatever bin/theme-toggle.sh last
-- set; a live toggle re-applies via the toggle script's RPC.
local _xdg = os.getenv("XDG_CONFIG_HOME")
local _cfg_theme_path = (_xdg and _xdg ~= "" and _xdg or vim.fn.expand("~/.config")) .. "/cfg-theme"
local _theme = "dark"
if vim.fn.filereadable(_cfg_theme_path) == 1 then
  local _ok, _lines = pcall(vim.fn.readfile, _cfg_theme_path)
  if _ok and _lines and _lines[1] == "light" then
    _theme = "light"
  end
end
local _sel_bg = (_theme == "light") and "#eee8d5" or "#3c3c3c"
vim.api.nvim_set_hl(0, "Visual", { bg = _sel_bg })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = _sel_bg })
vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = _sel_bg })
