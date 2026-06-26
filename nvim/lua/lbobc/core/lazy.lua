-- Bootstrap lazy.nvim, pinned to a specific commit (supply-chain hardening:
-- clone the moving `stable` branch could pull whatever HEAD is at clone time).
-- Bump deliberately; verify the target with:
--   git ls-remote https://github.com/folke/lazy.nvim.git stable
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazycommit = "332b4cbc8bf61589b6ff58ce42fca80173154669" -- `stable` tag as of 2026-06-26
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("failed to clone lazy.nvim:\n" .. out)
  end
  out = vim.fn.system({ "git", "-C", lazypath, "checkout", "--detach", lazycommit })
  if vim.v.shell_error ~= 0 then
    error("failed to pin lazy.nvim to " .. lazycommit .. ":\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "lbobc.plugins" } },
  change_detection = { notify = false },
})
