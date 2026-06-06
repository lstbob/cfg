return {
  "L3MON4D3/LuaSnip",
  event = "InsertEnter",
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    -- Load snippets for C# filetype
    ls.add_snippets("cs", {
      -- 1. cdesc/
      s("/ccd/", {
        t({ "/// <summary>", "/// " }), i(1, "*"), t({ "", "/// </summary>" }),
      }),

      s("/cld/", {
        t({ "/// <summary>", "/// Represents " }), i(1, "*"), t({ "", "/// </summary>" }),
      }),

      -- 2. ctordesc/
      s("/cd/", {
        t({ "/// <summary>", "/// Initializes a new instance of <see cref=\"" }),
        i(1, "*"), t({ "\"/>", "/// </summary>" }),
      }),

      -- 3. mdesc/
      s("/md/", {
        t({ "/// <summary>", "/// Responsible for " }), i(1, "*"), t({ "", "/// </summary>" }),

        t({ "", "/// <param name=\"" }), i(2, "*"), t({ "\">" }), i(3, "*"), t({ "</param>" }),
        t({ "", "/// <param name=\"" }), i(4, "*"), t({ "\">" }), i(5, "*"), t({ "</param>" }),
        t({ "", "/// <param name=\"" }), i(6, "*"), t({ "\">" }), i(7, "*"), t({ "</param>" }),
        t({ "", "/// <param name=\"" }), i(8, "*"), t({ "\">" }), i(9, "*"), t({ "</param>" }),

        t({ "", "/// <exception cref=\"" }), i(10, "*"), t({ "\">" }), i(11, "*"), t({ "</exception>" }),
        t({ "", "/// <returns>" }), i(12, "*"), t({ ".</returns>" }),
      }),

      s("/utaaa/", {
        t("// Arrange"), t({ "", "" }), i(1, "*"), t({ "", "// Act" }), t({ "", "" }), i(2, "*"),
        t({ "", "// Assert" }), t({ "", "" }), i(3, "*"),
      })
    })

    -- <Tab> to expand snippet or jump
    vim.api.nvim_set_keymap("i", "<Tab>",
      [[luasnip#expand_or_jumpable() ? "<Plug>luasnip-expand-or-jump" : "<Tab>"]],
      { expr = true, noremap = true }
    )

    vim.api.nvim_set_keymap("s", "<Tab>",
      [[<cmd>lua require'luasnip'.jump(1)<Cr>]],
      { noremap = true }
    )

    vim.api.nvim_set_keymap("i", "<S-Tab>",
      [[<cmd>lua require'luasnip'.jump(-1)<Cr>]],
      { noremap = true }
    )

    vim.api.nvim_set_keymap("s", "<S-Tab>",
      [[<cmd>lua require'luasnip'.jump(-1)<Cr>]],
      { noremap = true }
    )
  end,
}
