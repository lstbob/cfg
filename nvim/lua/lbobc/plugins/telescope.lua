return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Native fzf sorter: adds fzf search operators in the prompt, e.g.
    --   Service.cs$  (ends with)   ^src (starts with)   'exact   !exclude
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        -- Near-fullscreen horizontal layout: wide results column for long
        -- file names + a large preview that is always shown.
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            width = 0.95,
            height = 0.95,
            preview_width = 0.45,
            preview_cutoff = 0, -- always show the preview, even when narrow
          },
        },
        -- Truncate long paths from the left so the file name stays visible.
        path_display = { "truncate" },
      },
      extensions = {
        fzf = {
          fuzzy = true,                   -- false = exact-match only
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",       -- case-insensitive unless you type uppercase
        },
      },
    })
    require("telescope").load_extension("fzf") -- enable the native sorter + operators

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
    vim.keymap.set("n", "<leader>fs", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end)

    -- Grep a string, but only within files matching a glob (e.g. *Service.cs).
    -- Leave the glob empty to search everywhere (same as <leader>fs).
    vim.keymap.set("n", "<leader>fS", function()
      local search = vim.fn.input("Grep > ")
      if search == "" then return end
      local glob = vim.fn.input("File glob (e.g. *Service.cs) > ")
      local opts = { search = search }
      if glob ~= "" then
        opts.glob_pattern = glob
      end
      builtin.grep_string(opts)
    end, { desc = "Grep string within files matching a glob" })

    vim.keymap.set("n", "<leader>gc", function()
      local word = vim.fn.expand("<cword>") -- e.g., "AccountEntity"
      local pattern = string.format(
        [[\b(public|private|protected|internal)\s+(static|abstract|sealed|virtual)?\s*(class|enum|interface|record)\s+\b%s\b]],
        word
      )
      builtin.grep_string({ search = pattern, use_regex = true })
    end)

    vim.keymap.set("n", "<leader>gm", function()
      local method_name = vim.fn.expand("<cword>") -- word under cursor (e.g., "GetAccountFromDb")
      local pattern = string.format(
        [[\b(public|private|internal|protected)\s+(static|virtual|abstract|override)?\s+([\w<>,\s]+?)\s+%s\b]],
        method_name
      )
      builtin.grep_string({
        search = pattern,
        use_regex = true,
        word_match = "-w",       -- Match whole words only
        case_mode = "smart_case" -- Case-sensitive only if uppercase
      })
    end)

    -- Project-wide grep of the word under the cursor (every textual occurrence).
    -- Moved off <leader>fr so that key is exclusively LSP find-references.
    vim.keymap.set("n", "<leader>fw", function()
      local word = vim.fn.expand("<cword>") -- Get the word under cursor
      builtin.grep_string({ search = word }) -- Auto-search without input()
    end)
  end,
}
