local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  -- local pivot_panes = wezterm.plugin.require("https://github.com/chrisgve/pivot_panes.wezterm")

  -- pivot_panes.setup({
  --   max_scrollback_lines = 1000,
  --   debug = false,
  --   priority_apps = {
  --     -- ["less"] = 5,
  --     -- ["nvim"] = 3,
  --   },
  -- })

  -- config.keys = config.keys or {}
  -- table.insert(config.keys, {
  --   {
  --     mods = "CTRL|SHIFT",
  --     key = "R",
  --     action = wezterm.action_callback(pivot_panes.toggle_orientation_callback),
  --   },
  -- })

  return config
end

return M
