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
