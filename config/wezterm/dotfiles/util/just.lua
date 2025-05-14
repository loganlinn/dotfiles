local wezterm = require("wezterm")

local M = {}

M.execute = function(args)
  local command = {
    os.getenv("SHELL") or "zsh",
    "-l",
    "-c",
    [[exec just "$@"]],
    "-just",
  }
  for _, arg in ipairs(args) do
    table.insert(command, arg)
  end
  return wezterm.run_child_process(command)
end

M.dump_justfile = function(justfile)
  local ok, stdout, stderr = M.execute({ "--dump", "--dump-format=json", "--justfile", justfile })
  if not ok then
    error(stderr)
  end
  return wezterm.serde.json_decode(stdout)
end

return M
