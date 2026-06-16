return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip", -- exposes LuaSnip snippets as a cmp source
  },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      snippet = {
        -- REQUIRED if using snippets
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection
        ["<C-j>"] = cmp.mapping.select_next_item(),         -- Navigate next
        ["<C-k>"] = cmp.mapping.select_prev_item(),         -- Navigate previous
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- This sources from your LSP clients, including Roslyn
        { name = "luasnip" },  -- Snippets
      }, {
        { name = "buffer" },   -- Also suggests words from the current file
      })
    })
  end,
}
