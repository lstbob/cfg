return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        cs = { "csharpier" },
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
        htmlangular = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },
        less = { "prettierd", "prettier" },
        yaml = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        rust = { "rustfmt" },
        go = { "goimports" }, -- goimports = gofmt + auto add/remove imports on save
        python = { "black" },
        --    sql = { "sqlfluff" },
        c = { "clang_format" },
      },
      formatters = {
        clang_format = {
          -- GNU-based style: Allman braces (opening brace on a new line) +
          -- real tabs (width 4) for indentation, so manual editing and the
          -- formatter agree. ColumnLimit 100 matches the colorcolumn guide.
          prepend_args = {
            "--style={BasedOnStyle: GNU, UseTab: Always, TabWidth: 4, IndentWidth: 4, ContinuationIndentWidth: 4, ColumnLimit: 100}",
          },
        },
      },
      format_on_save = function(bufnr)
        local disable_auto_format = vim.b[bufnr].disable_autoformat or false
        if disable_auto_format then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    })

    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, { desc = "Format file" })
  end,
}
