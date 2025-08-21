local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("dotfiles.event.gui-startup")

-- local set_active_workspace = wezterm.mux.set_active_workspace
-- local get_window = wezterm.mux.get_window

wezterm.on("gui-startup", function(...)
  log.info(...)
end)
