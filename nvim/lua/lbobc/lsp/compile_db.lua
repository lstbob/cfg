local M = {}

function M.detect_compilation_db()
  local root = vim.fn.getcwd()
  if vim.fn.filereadable(root .. "/compile_commands.json") == 1 then
    return true
  end
  if vim.fn.filereadable(root .. "/compile_flags.txt") == 1 then
    return true
  end
  return false
end

function M.has_makefile()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/Makefile") == 1
end

function M.generate()
  local cwd = vim.fn.getcwd()

  if not M.has_makefile() then
    vim.notify("No Makefile found in " .. cwd, vim.log.levels.WARN)
    return
  end

  local out = vim.fn.system("make -B -n 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    vim.notify("make -B -n failed", vim.log.levels.ERROR)
    return
  end

  local entries = {}
  for line in out:gmatch("[^\r\n]+") do
    local cmd = line:match("^%s*(gcc%s.*)")
      or line:match("^%s*(clang%s.*)")
      or line:match("^%s*(g%+%+%s.*)")
    if cmd then
      local file = cmd:match("%-c%s+([^%s]+%.c)")
        or cmd:match("%-c%s+([^%s]+%.cpp)")
        or cmd:match("%-c%s+([^%s]+%.cc)")
        or cmd:match("%-c%s+([^%s]+%.cxx)")
      if file then
        table.insert(entries, {
          directory = cwd,
          command = cmd,
          file = file,
        })
      end
    end
  end

  if #entries == 0 then
    vim.notify("Could not find any compilation commands in make -B -n output", vim.log.levels.WARN)
    return
  end

  local json = vim.fn.json_encode(entries)
  vim.fn.writefile(vim.split(json, "\n"), "compile_commands.json")
  vim.notify("Generated compile_commands.json with " .. #entries .. " entries")
end

function M.auto_generate()
  if M.detect_compilation_db() then
    return
  end
  if not M.has_makefile() then
    return
  end
  local ok, err = pcall(M.generate)
  if not ok then
    vim.notify("compile_db generation failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

return M
