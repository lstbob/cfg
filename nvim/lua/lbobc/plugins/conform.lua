return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        cs = { "csharpier" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        htmlangular = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        less = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        rust = { "rustfmt" },
        go = { "goimports" }, -- goimports = gofmt + auto add/remove imports on save
        python = { "black" },
        --    sql = { "sqlfluff" },
        c = { "clang_format" },
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
