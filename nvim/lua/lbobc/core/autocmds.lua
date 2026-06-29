-- C/C++ indentation: real tabs (width 8) to match the Linux kernel
-- clang-format style configured in plugins/conform.lua. Global options.lua
-- sets expandtab=true (spaces); this per-buffer override switches C files
-- to tabs so manual autoindent and the formatter never fight.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function(args)
    vim.bo[args.buf].expandtab = false
    vim.bo[args.buf].tabstop = 8
    vim.bo[args.buf].shiftwidth = 8
    vim.bo[args.buf].softtabstop = 8
    -- Kernel column limit is 80; align the guide to the formatter.
    vim.wo[0].colorcolumn = "80"
  end,
})

-- Auto-generate compile_commands.json when opening C/C++ files
-- if the project has a Makefile but no compilation database yet.
-- Each directory is checked once (generate() skips if compile_commands.json exists).
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc", "*.cxx" },
  callback = function()
    require("lbobc.lsp.compile_db").auto_generate()
  end,
})

-- User command to manually regenerate
vim.api.nvim_create_user_command("GenCompileDb", function()
  require("lbobc.lsp.compile_db").generate()
end, { desc = "Generate compile_commands.json from Makefile" })

-- C# namespace + type declaration autogeneration for newly created .cs files
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cs",
  callback = function()
    local filepath = vim.fn.expand("%:p")
    filepath = filepath:gsub("\\", "/")
    print("\nCreating file: " .. filepath .. "\n")
    local rel = filepath:match(".-/src/(.+)") or filepath:match(".-/tests/(.+)")
    if not rel then
      print("\nCould not extract relative path after src/ or tests/\n")
      return
    end
    rel = rel:gsub("%.cs$", "")
    rel = rel:gsub("/[^/]+$", "")
    local ns = rel:gsub("/", ".")
    local name = filepath:match("([^/\\]+)%.cs$")
    if not name then
      print("\nCould not extract class/interface name from filename\n")
      return
    end
    local decl_lines
    if name:sub(1, 1) == "I" and name:sub(2, 2):match("%u") then
      decl_lines = {
        ("public interface %s"):format(name),
        "{",
        "    ",
        "}"
      }
    else
      decl_lines = {
        ("public class %s"):format(name),
        "{",
        "    ",
        "}"
      }
    end
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "namespace " .. ns .. ";", "" })
    vim.api.nvim_buf_set_lines(0, 2, 2, false, decl_lines)
    -- Move cursor to the indented line inside the block and enter insert mode
    vim.api.nvim_win_set_cursor(0, { 5, 5 }) -- line 5, column 5 (4 spaces in)
    vim.cmd("startinsert")
    print("\nInserted namespace and declaration!\n")
  end,
})

-- Subtle background for floating windows + popup/scroll menus under rose-pine.
-- Editor `Normal` stays transparent (Alacritty opacity); only floats/popups get
-- a surface lift so hover/diagnostic/telescope/completion/LspInfo boxes are
-- readable against the code. Re-applies on every colorscheme reload.
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "rose-pine",
  callback = function()
    local ok, p = pcall(require, "rose-pine.palette")
    if not ok then
      return
    end
    -- all floating windows (hover <leader>dd, diagnostic <leader>se,
    -- <S-j>/<S-k>, telescope, code-action, rename, LspInfo, notify, dap-ui, which-key ...)
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = p.surface })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.pine, bg = p.surface })
    -- completion popup (nvim-cmp) + its scrollbar
    vim.api.nvim_set_hl(0, "Pmenu", { bg = p.surface })
    vim.api.nvim_set_hl(0, "PmenuExtra", { bg = p.surface })
    vim.api.nvim_set_hl(0, "PmenuKind", { bg = p.surface })
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = p.overlay, fg = p.text })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = p.surface })
    vim.api.nvim_set_hl(0, "PmenuThumb", { bg = p.muted })
  end,
})
