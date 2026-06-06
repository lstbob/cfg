return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- pin to the classic API (the `main` rewrite changes setup())
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c_sharp", "c", "go", "python", "rust", "lua",
        "angular", "typescript", "tsx", "javascript", "html", "css", "scss",
      },
      highlight = { enable = true },
      indent = { enable = true },
      auto_install = true,
    })
  end,
}
