-- nvim-dap configuration for .NET (netcoredbg)
local ok, dap = pcall(require, "dap")
if not ok then
  return
end

-- Resolve netcoredbg path.
-- Prefers Mason's install (`:MasonInstall netcoredbg`), falls back to $PATH.
local mason_netcoredbg = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
local netcoredbg_cmd = vim.fn.filereadable(mason_netcoredbg) == 1
    and mason_netcoredbg
    or "netcoredbg"

-- Adapter: netcoredbg speaks DAP when invoked with --interpreter=vscode
dap.adapters.coreclr = {
  type = "executable",
  command = netcoredbg_cmd,
  args = { "--interpreter=vscode" },
}

-- Also register under `netcoredbg` name for configs that use that key
dap.adapters.netcoredbg = dap.adapters.coreclr

-- Remember the last-picked dll across runs so <leader>dl / re-runs don't re-prompt
local last_dll = nil

local function pick_dll()
  local cwd = vim.fn.getcwd()
  local default = last_dll
      or vim.fn.glob(cwd .. "/**/bin/Debug/**/*.dll", false, true)[1]
      or (cwd .. "/bin/Debug/")
  local choice = vim.fn.input({
    prompt = "Path to dll: ",
    default = default,
    completion = "file",
  })
  if choice ~= "" then last_dll = choice end
  return choice
end

-- Default cwd to the directory containing the dll (so appsettings.json etc. resolve)
local function dll_dir()
  if last_dll and last_dll ~= "" then
    return vim.fn.fnamemodify(last_dll, ":h")
  end
  return vim.fn.getcwd()
end

local dotnet_config = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = pick_dll,
    cwd = dll_dir,
    stopAtEntry = false,
    console = "internalConsole",
    env = {
      ASPNETCORE_ENVIRONMENT = "Development",
      DOTNET_ENVIRONMENT = "Development",
    },
  },
  {
    type = "coreclr",
    name = "attach - netcoredbg (pick process)",
    request = "attach",
    processId = function()
      -- Only show running .NET API processes (native apphost or `dotnet exec X.API.dll`).
      -- Excludes MSBuild nodes, roslyn LSP, daprd, dotnet run/watch wrappers, AppHost, etc.
      return require("dap.utils").pick_process({
        filter = function(proc)
          local n = proc.name or ""
          if n == "" then return false end
          -- Build-time / tooling noise
          if n:find("MSBuild", 1, true)
              or n:find("LanguageServer", 1, true)
              or n:find("roslyn", 1, true)
              or n:find("daprd", 1, true)
              or n:find("Aspire.Dashboard", 1, true)
          then
            return false
          end
          -- `dotnet run` / `dotnet watch` wrappers spawn the real apphost as a child;
          -- attach to the child, not the wrapper.
          if n:match("^dotnet%s+run%s") or n:match("^dotnet%s+watch%s") then
            return false
          end
          -- Must live in a build output directory (excludes stray dotnet CLIs)
          if not (n:find("/bin/Debug/", 1, true) or n:find("/bin/Release/", 1, true)) then
            return false
          end
          -- Must look like an API: ends in .API / .Api, or is dotnet exec *.API.dll / *.Api.dll
          return n:match("%.API$") or n:match("%.Api$")
              or n:match("%.API[^%w]") or n:match("%.Api[^%w]")
        end,
      })
    end,
  },
}

dap.configurations.cs = dotnet_config
dap.configurations.fsharp = dotnet_config
dap.configurations.vb = dotnet_config

-- Custom DAP highlight groups (distinct from LSP diagnostics so signs stand out)
vim.api.nvim_set_hl(0, "DapBreakpointHl",          { fg = "#ef5350", bold = true })   -- bright red
vim.api.nvim_set_hl(0, "DapBreakpointConditionHl", { fg = "#ffb74d", bold = true })   -- amber
vim.api.nvim_set_hl(0, "DapLogPointHl",            { fg = "#64b5f6", bold = true })   -- sky blue
vim.api.nvim_set_hl(0, "DapStoppedHl",             { fg = "#a5d6a7", bold = true })   -- soft green
vim.api.nvim_set_hl(0, "DapStoppedLineHl",         { bg = "#2e4a2e" })                -- dark green line bg
vim.api.nvim_set_hl(0, "DapBreakpointRejectedHl",  { fg = "#78909c", italic = true }) -- slate gray
vim.api.nvim_set_hl(0, "NvimDapVirtualText",       { fg = "#c792ea", italic = true }) -- purple for inline values

-- Breakpoint signs (ASCII so they render without a Nerd Font)
vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpointHl",          linehl = "",                numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointConditionHl", linehl = "",                numhl = "" })
vim.fn.sign_define("DapLogPoint",            { text = "◉", texthl = "DapLogPointHl",            linehl = "",                numhl = "" })
vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStoppedHl",             linehl = "DapStoppedLineHl", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected",  { text = "✖", texthl = "DapBreakpointRejectedHl",  linehl = "",                numhl = "" })

-- dap-ui: auto-open on session start, close on termination
local ok_ui, dapui = pcall(require, "dapui")
if ok_ui then
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
end

-- Inline variable values while stepping
local ok_vt, vt = pcall(require, "nvim-dap-virtual-text")
if ok_vt then
  vt.setup({ commented = true })
end

-- Keymaps
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

map("<leader>db", function() dap.continue() end,           "DAP: continue / start")
map("<leader>dc", function() dap.continue() end,           "DAP: continue / start")
map("<leader>dn", function() dap.step_over() end,          "DAP: step over (next)")
map("<leader>di", function() dap.step_into() end,          "DAP: step into")
map("<leader>do", function() dap.step_out() end,           "DAP: step out")
map("<leader>bp", function() dap.toggle_breakpoint() end,  "DAP: toggle breakpoint")
map("<leader>B",  function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, "DAP: conditional breakpoint")
map("<leader>lp", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, "DAP: log point")
map("<leader>dr", function() dap.repl.open() end,          "DAP: open REPL")
map("<leader>dl", function() dap.run_last() end,           "DAP: run last")
map("<leader>dt", function() dap.terminate() end,          "DAP: terminate")
if ok_ui then
  map("<leader>du", function() dapui.toggle() end,         "DAP: toggle UI")
  map("<leader>de", function()
    dapui.eval(nil, { enter = true, width = 120, height = 30 })
  end, "DAP: eval expression")
end
