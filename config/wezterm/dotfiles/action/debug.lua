local wezterm = require("wezterm")
local debug = require("dotfiles.util.debug")

local M = {}

M.DumpWindow = wezterm.action_callback(function(window, _)
  debug.inspect(window, debug.dump_window(window), tostring(window))
end)

M.DumpPane = wezterm.action_callback(function(window, pane)
  debug.inspect(window, debug.dump_pane(pane), tostring(pane))
end)

M.ToggleDebugKeyEvents = wezterm.action_callback(function(window, _)
  apply_to_config_overrides(function(overrides)
    overrides.debug_key_events = not overrides.debug_key_events
    return overrides
  end, window)
end)

return M
