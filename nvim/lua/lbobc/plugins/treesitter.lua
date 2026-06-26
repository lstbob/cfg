return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").setup({})
    local ensure_installed = {
      "c_sharp", "c", "go", "python", "rust", "lua",
      "angular", "typescript", "tsx", "javascript", "html", "css", "scss",
    }
    local installed = require("nvim-treesitter.config").get_installed()
    local to_install = vim.tbl_filter(function(lang)
      return not vim.list_contains(installed, lang)
    end, ensure_installed)
    if #to_install > 0 then
      require("nvim-treesitter").install(to_install):wait(300000)
    end
  end,
}
