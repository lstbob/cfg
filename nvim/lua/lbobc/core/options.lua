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

-- cfg shared theme state: read once at startup. "light" = Solarized Light
-- (bright room); default "dark" (soft gray). Drives nvim's `background` so the
-- built-in default colorscheme (no plugin) repaints syntax text to match.
-- The transparent-editor + float/selection overrides live in a ColorScheme
-- autocmd (autocmds.lua) so they survive every colorscheme reapply, including
-- the deferred one triggered by setting `background` here and any live toggle.
local _xdg = os.getenv("XDG_CONFIG_HOME")
local _cfg_theme_path = (_xdg and _xdg ~= "" and _xdg or vim.fn.expand("~/.config")) .. "/cfg-theme"
local _theme = "dark"
if vim.fn.filereadable(_cfg_theme_path) == 1 then
  local _ok, _lines = pcall(vim.fn.readfile, _cfg_theme_path)
  if _ok and _lines and _lines[1] == "light" then
    _theme = "light"
  end
end
vim.g.cfg_theme = _theme

-- Apply transparent editor bg + slight-grey floats + dim selection bg. Done in
-- THREE places for robustness against plugin/colorscheme reapply timing:
--  * inline below (synchronous at startup -- works even when `background` is
--    already the target value and so fires no ColorScheme event, e.g. dark);
--  * a ColorScheme autocmd registered BEFORE `background` is set, so it catches
--    the fire from the dark<->light flip (and any later plugin reapply);
--  * re-applied by bin/theme-toggle.sh on a live toggle.
local _apply_cfg_theme_hl = function()
  local t = vim.g.cfg_theme or "dark"
  local float_bg = (t == "light") and "#efeadb" or "#252525"
  local sel_bg = (t == "light") and "#eee8d5" or "#3c3c3c"
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = float_bg })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = float_bg })
  vim.api.nvim_set_hl(0, "Visual", { bg = sel_bg })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = sel_bg })
  vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = sel_bg })
end
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = _apply_cfg_theme_hl })
_apply_cfg_theme_hl()

-- Flip nvim's background to match the terminal palette. Re-applies the default
-- colorscheme; the ColorScheme autocmd above re-runs our overrides after it.
vim.o.background = _theme
_apply_cfg_theme_hl()
