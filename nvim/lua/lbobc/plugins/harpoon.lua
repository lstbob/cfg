return {
  "theprimeagen/harpoon",
  event = "VeryLazy",
  config = function()
    -- Size the quick-menu popup to (almost) the full editor so long file
    -- paths aren't truncated. Computed once at startup; harpoon's setup()
    -- reads config off disk on each call, so we don't re-run it on resize.
    require("harpoon").setup({
      menu = {
        width = math.max(60, math.floor(vim.o.columns * 0.9)),
        height = math.max(10, math.floor(vim.o.lines * 0.6)),
      },
    })

    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")
    vim.keymap.set("n", "<leader>af", mark.add_file)
    vim.keymap.set("n", "<leader>sf", ui.toggle_quick_menu)
    vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
    vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
    vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
    vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
    vim.keymap.set("n", "<leader>5", function() ui.nav_file(5) end)
  end,
}
