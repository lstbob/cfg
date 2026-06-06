-- Shared building blocks for every LSP server config.
local M = {}

-- Same LSP keymaps for every server (buffer-local, set on attach).
M.on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("<leader>fr", vim.lsp.buf.references, "[G]oto [R]eferences")
  nmap("<leader>gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>dd", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<leader>se", vim.diagnostic.open_float, "Show [E]rror")
  nmap("<S-j>", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next [D]iagnostic")
  nmap("<S-k>", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev [D]iagnostic")
end

-- nvim-cmp capabilities so completion works against every server.
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_lsp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
M.capabilities = capabilities

-- Resolve a Mason `bin/<tool>` to its realpath.
-- Mason's bin entries are symlinks into a node_modules `.bin/` shim that does
-- `dirname "$0"` + relative `..`; called via the symlink, $0 is the symlink so
-- the lookup lands one directory too high. Resolving to the realpath starts the
-- relative lookup inside the package's own node_modules/.
local fn, uv = vim.fn, vim.uv
function M.mason_bin(name)
  local exe = fn.exepath(name)
  if exe and #exe > 0 then
    return uv.fs_realpath(exe) or exe
  end
  return name
end

return M
