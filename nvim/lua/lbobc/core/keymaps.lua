-- General key mappings (leader is set in init.lua, before lazy loads)

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("Explore " .. vim.fn.expand("%:p:h"))
end)
vim.keymap.set("n", "C-a", vim.cmd(""))
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- move lines when in visual mode
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- nvim config editing
vim.keymap.set("n", "<leader>`", function()
  vim.cmd("tabnew $MYVIMRC<CR>")
  vim.cmd("lcd ~/.config/nvim/")
  vim.cmd("Ex")
end, { desc = "edit vimrc" })

-- copy / paste config
vim.keymap.set("n", "<C-c>", '"+yy', { noremap = true, silent = true }) -- copy current line
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true })  -- copy current line in vis mode

vim.keymap.set("n", "<C-v>", '"+p', { noremap = true, silent = true })   -- paste line normal
vim.keymap.set("v", "<C-v>", "<C-r>+", { noremap = true, silent = true }) -- paste line insert

-- terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exiting terminal " })
vim.keymap.set("n", "<leader>tt", function()
  vim.cmd("10split | terminal")
end, { desc = "terminal at the bottom" }) -- Open split window with terminal

-- find and replace in all files
vim.keymap.set("n", "<leader>rr", function()
  local old_word = vim.fn.expand("<cword>")
  old_word = vim.fn.input("Find exact word: ", old_word)
  if old_word == "" then return end
  local new_word = vim.fn.input("Replace with: ")
  vim.cmd("vimgrep /\\<" .. old_word .. "\\>/gj **/*.cs")
  vim.cmd("cfdo %s/\\<" .. old_word .. "\\>/" .. new_word .. "/g | update")
end, { desc = "Find and replace in all .cs files (current word)" })

-- find and replace in file
vim.keymap.set("n", "<leader>rf", function()
  local old_word = vim.fn.expand("<cword>")
  old_word = vim.fn.input("Find exact word: ", old_word)
  if old_word == "" then return end
  local new_word = vim.fn.input("Replace with: ")
  -- Escape slashes and special chars in old_word and new_word
  old_word = vim.fn.escape(old_word, "\\/.*$^~[]")
  new_word = vim.fn.escape(new_word, "\\/")
  -- Build the command
  local cmd = string.format("%%s/\\<%s\\>/%s/gc", old_word, new_word)
  vim.cmd(cmd)
end, { desc = "Find and replace in current file (current word)" })

-- new tab
vim.keymap.set("n", "<leader>nt", function()
  vim.cmd("tabnew")
  vim.cmd("Ex")
end, { desc = "New tab with file explorer" })

-- close tab
vim.keymap.set("n", "<leader>ct", function()
  vim.cmd("tabc")
  vim.cmd("Ex")
end, { desc = "Close tab with file explorer" })

-- toggle background dark/light
vim.keymap.set("n", "<leader>tb", function()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end, { desc = "Toggle background dark/light" })
