local wezterm = require("wezterm")
local M = {}

function M.apply_to_config(config)
  local launch_menu = config.launch_menu or {}
  for _, src_dir in ipairs(wezterm.glob("github.com/*/*", wezterm.home_dir .. "/src")) do
    table.insert(launch_menu, {
      label = "Workspace: " .. src_dir,
      args = { "zshi", 'wezterm cli rename-workspace "${PWD:t2}' },
      cwd = src_dir,
    })
  end
  config.launch_menu = launch_menu
  return config
end

return M
