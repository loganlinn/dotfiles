local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("dotfiles.event.window-config-reloaded")

wezterm.on("window-config-reloaded", function(window, _pane)
  log.info("the config was reloaded for", window)
end)
