local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("dotfiles.event.window-focus-changed")

wezterm.on("window-focus-changed", function(window, pane)
  log.info("the focus state of ", window:window_id(), " changed to ", window:is_focused())
end)
