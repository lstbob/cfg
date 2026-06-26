-- csharp_doc.lua — Visual-Studio-style `///` XML doc generation for C#.
--
-- Type `///` on the line ABOVE a member (or invoke :CsDoc) and this expands a
-- doc comment tailored to the declaration below the cursor, using Treesitter to
-- parse it:
--   * <summary>                         (always)
--   * <typeparam name="T">              (one per generic type parameter)
--   * <param name="x">                  (one per parameter; incl. primary ctors
--                                        and positional records)
--   * <returns>                         (methods/delegates/operators/indexers
--                                        with a non-void return type)
--   * <exception cref="...">            (scanned from `throw new X(...)` in the
--                                        body — beyond VS; toggle via scan_throws)
--
-- Every text slot is a LuaSnip insert node, so <Tab>/<S-Tab> walk them in order
-- (see luasnip.lua for the jump keymaps).

local M = {}

-- Scan member bodies for `throw new X(...)` and emit <exception> tags.
-- Set false to match Visual Studio exactly (summary/typeparam/param/returns only).
M.scan_throws = true

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node

-- Declaration node types we know how to document.
local DECL = {
  class_declaration = true,
  interface_declaration = true,
  struct_declaration = true,
  record_declaration = true,
  record_struct_declaration = true,
  enum_declaration = true,
  method_declaration = true,
  constructor_declaration = true,
  destructor_declaration = true,
  delegate_declaration = true,
  operator_declaration = true,
  conversion_operator_declaration = true,
  indexer_declaration = true,
  property_declaration = true,
  local_function_statement = true,
  -- Fields/events get a <summary> only, but must be recognized so the comment
  -- aligns to the field rather than ascending to the enclosing type.
  field_declaration = true,
  event_field_declaration = true,
  event_declaration = true,
}

-- Declarations that carry a return value worth a <returns> tag.
local RETURNS = {
  method_declaration = true,
  delegate_declaration = true,
  operator_declaration = true,
  conversion_operator_declaration = true,
  indexer_declaration = true,
  local_function_statement = true,
}

-- Member bodies worth scanning for thrown exceptions.
local MEMBER = {
  method_declaration = true,
  constructor_declaration = true,
  destructor_declaration = true,
  operator_declaration = true,
  conversion_operator_declaration = true,
  indexer_declaration = true,
  property_declaration = true,
  local_function_statement = true,
}

local function ntext(node, bufnr)
  if not node then return nil end
  return vim.treesitter.get_node_text(node, bufnr)
end

-- Ascend from the first non-blank line below `row` (0-based) to the nearest
-- declaration node. Returns the node or nil.
local function decl_below(bufnr, row)
  -- Ask for the C# parser explicitly (by language, not filetype) and parse it.
  -- nvim-treesitter's `main` branch doesn't auto-attach a parser, so relying on
  -- get_node()'s implicit buffer-language resolution returns nil otherwise.
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "c_sharp")
  if not ok or not parser then return nil end
  parser:parse(true)

  local last = vim.api.nvim_buf_line_count(bufnr)
  for r = row + 1, last - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, r, r + 1, false)[1]
    if line and line:match("%S") then
      local col = #(line:match("^%s*") or "")
      local got, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { r, col }, lang = "c_sharp" })
      if not got then return nil end
      while node do
        if DECL[node:type()] then return node end
        node = node:parent()
      end
      return nil
    end
  end
  return nil
end

-- Pull names/return/exceptions out of a declaration node.
local function parse(decl, bufnr)
  local kind = decl:type()
  local info = { kind = kind, typeparams = {}, params = {}, has_return = false, exceptions = {} }

  for child in decl:iter_children() do
    local ct = child:type()
    if ct == "type_parameter_list" then
      for tp in child:iter_children() do
        if tp:type() == "type_parameter" then
          local name = tp:field("name")[1]
          table.insert(info.typeparams, name and ntext(name, bufnr) or ntext(tp, bufnr))
        end
      end
    elseif ct == "parameter_list" then
      for p in child:iter_children() do
        if p:type() == "parameter" then
          local name = p:field("name")[1]
          if name then table.insert(info.params, ntext(name, bufnr)) end
        end
      end
    end
  end

  if RETURNS[kind] then
    local ret = decl:field("returns")[1] or decl:field("type")[1]
    local rt = ret and ntext(ret, bufnr)
    info.has_return = rt ~= nil and rt ~= "void"
  end

  if M.scan_throws and MEMBER[kind] then
    local seen = {}
    for ex in (ntext(decl, bufnr) or ""):gmatch("throw%s+new%s+([%w_%.]+)") do
      if not seen[ex] then
        seen[ex] = true
        table.insert(info.exceptions, ex)
      end
    end
  end

  return info
end

-- Indentation of the line a node starts on.
local function indent_of(bufnr, srow)
  return (vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""):match("^%s*") or ""
end

-- Build the snippet_node for the doc comment, reading the buffer at expand time.
-- Both entry points (the `///` autosnippet and :CsDoc) arrange for expansion to
-- start at column 0 on an empty line, so we own the indentation outright and
-- align every line to the *declaration's* indent — never to wherever the cursor
-- happened to land. That makes the cursor column irrelevant.
local function doc_nodes()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  local ok, decl = pcall(decl_below, bufnr, row)
  local info = (ok and decl) and parse(decl, bufnr) or nil

  -- Align to the member below; fall back to the current line's own indent.
  local ind = decl and indent_of(bufnr, (decl:range())) or indent_of(bufnr, row)

  local nodes = {}
  local idx = 0
  local function slot()
    idx = idx + 1
    return i(idx)
  end
  local function line(open, close)
    vim.list_extend(nodes, { t({ "", ind .. open }), slot(), t(close) })
  end

  vim.list_extend(nodes, { t({ ind .. "/// <summary>", ind .. "/// " }), slot(), t({ "", ind .. "/// </summary>" }) })

  if info then
    for _, tp in ipairs(info.typeparams) do
      line(string.format('/// <typeparam name="%s">', tp), "</typeparam>")
    end
    for _, p in ipairs(info.params) do
      line(string.format('/// <param name="%s">', p), "</param>")
    end
    if info.has_return then
      line("/// <returns>", "</returns>")
    end
    for _, ex in ipairs(info.exceptions) do
      line(string.format('/// <exception cref="%s">', ex), "</exception>")
    end
  end

  return sn(nil, nodes)
end

function M.setup()
  ls.add_snippets("cs", {
    s(
      {
        trig = "///",
        name = "XML doc",
        desc = "Visual-Studio-style /// doc comment",
        wordTrig = false,
        -- Only fire when `///` is the whole (trimmed) line, so it never hijacks
        -- inline triple-slashes or continuation lines.
        condition = function(line_to_cursor) return line_to_cursor:match("^%s*///$") ~= nil end,
        -- Wipe the whole line (leading whitespace + `///`) so expansion starts at
        -- column 0 and doc_nodes controls indentation — see its comment.
        -- NOTE: LuaSnip reads resolveExpandParams from the context (this table),
        -- not from the opts table.
        resolveExpandParams = function(_, _, match, captures)
          local r, c = unpack(vim.api.nvim_win_get_cursor(0))
          return { clear_region = { from = { r - 1, 0 }, to = { r - 1, c } }, trigger = match, captures = captures }
        end,
      },
      { d(1, doc_nodes) }
    ),
  }, { type = "autosnippets" })

  -- Manual trigger: clear the current line first so expansion starts at column 0,
  -- matching the `///` path.
  vim.api.nvim_create_user_command("CsDoc", function()
    local r = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, r - 1, r, false, { "" })
    vim.api.nvim_win_set_cursor(0, { r, 0 })
    ls.snip_expand(s("", { d(1, doc_nodes) }))
  end, { desc = "Generate an XML doc comment for the C# member below the cursor" })
end

return M
