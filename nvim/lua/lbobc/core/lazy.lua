-- Bootstrap lazy.nvim (clone the stable tag on first run)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "lbobc.plugins" } },
  change_detection = { notify = false },
  -- We intentionally load NO colorscheme plugin (the built-in habamax stays, and
  -- we drive `vim.o.background` from ~/.config/cfg-theme). Without this, lazy's
  -- install_missing() runs its fallback `colorscheme habamax`, which resets
  -- `background=dark` and clobbers our light mode. {"default"} is lazy's sentinel
  -- that makes the fallback loop break immediately (no colorscheme call).
  install = { colorscheme = { "default" } },
})
