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
          -- Linux kernel style: function opening brace on a new line,
          -- if/else/for/while braces on the same line (BreakBeforeBraces:
          -- Linux), real tabs (width 8), column limit 80. Mirrors the
          -- .clang-format in torvalds/linux so manual editing and the
          -- formatter agree.
          prepend_args = {
            "--style={BasedOnStyle: LLVM, BreakBeforeBraces: Linux, UseTab: Always, TabWidth: 8, IndentWidth: 8, ContinuationIndentWidth: 8, ColumnLimit: 80, SortIncludes: false, AllowShortBlocksOnASingleLine: false, AllowShortCaseLabelsOnASingleLine: false, AllowShortIfStatementsOnASingleLine: Never, AllowShortLoopsOnASingleLine: false, SpaceAfterCStyleCast: false, AlignTrailingComments: true}",
          },
        },
      },
      format_on_save = function(bufnr)
        local disable_auto_format = vim.b[bufnr].disable_autoformat or false
        if disable_auto_format then
          return
        end
        -- clang-format is the authoritative C/C++ formatter (Linux kernel
        -- style + tabs, configured above). Never fall back to clangd's LSP
        -- formatting, which uses the LLVM default (K&R braces + 2 spaces)
        -- and would fight clang-format.
        local ft = vim.bo[bufnr].filetype
        if ft == "c" or ft == "cpp" then
          return { timeout_ms = 2000, lsp_fallback = false }
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    })

    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, { desc = "Format file" })
  end,
}
