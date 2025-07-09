local wezterm = require("wezterm")

local smart_workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local M = {}

function M.apply_to_config(config)
  smart_workspace_switcher.apply_to_config(config)

  config.keys = config.keys or {}
  table.insert(config.keys, {
    mods = "LEADER",
    key = "Space",
    action = smart_workspace_switcher.switch_workspace({
      -- filter `zoxide query -l` output
      extra_args = " | rg -x -e ~'/src/([^/]+/?){3}'",
    }),
  })
  table.insert(config.keys, {
    mods = "LEADER",
    key = "Tab",
    action = smart_workspace_switcher.switch_to_prev_workspace(),
  })

  return config
end

return M
