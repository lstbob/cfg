-- options
vim.opt.swapfile=false
vim.opt.backup=false
vim.opt.scrolloff=8
vim.opt.splitbelow=true
vim.opt.shellxquote=""
vim.opt.cursorline=true
vim.opt.guicursor=""
vim.opt.termguicolors=true
vim.opt.hlsearch=false
vim.opt.incsearch=true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"
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
vim.g.netrw_banner = 0         -- Hide help banner
vim.g.netrw_winsize = 25      -- Set window width
vim.g.netrw_altv = 1          -- Vertical splits to the right
vim.opt.ignorecase=true
vim.opt.smartcase=true

vim.keymap.set('n', '<leader>tb', function()
  if vim.o.background == 'dark' then
    vim.o.background = 'light'
  else
    vim.o.background = 'dark'
  end
end, { desc = 'Toggle background dark/light' })
