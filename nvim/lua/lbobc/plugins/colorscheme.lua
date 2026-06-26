return {
  "rose-pine/neovim",
  name = "rose-pine", -- repo is named "neovim"; force the plugin/module name
  lazy = false,       -- load during startup (this is the main UI colorscheme)
  priority = 1000,    -- load before other plugins so highlights apply cleanly
  opts = {
    variant = "auto",      -- auto: dark_variant when bg=dark, dawn when bg=light
    dark_variant = "main", -- main | moon (used when background is dark)
    styles = {
      transparency = true, -- matches the transparent-background / Alacritty opacity setup
      italic = false,       -- disable italics (C# vars/props/params/types are italic by default)
    },
  },
  config = function(_, opts)
    require("rose-pine").setup(opts)
    vim.cmd.colorscheme("rose-pine")
  end,
}
