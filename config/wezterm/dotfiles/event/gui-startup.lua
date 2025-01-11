local wezterm = require("wezterm")
local util = require("dotfiles.util")
local log = require("dotfiles.util.logger").new("dotfiles.event.gui-startup")

-- https://wezfurlong.org/wezterm/config/lua/gui-events/gui-startup.html
wezterm.on("gui-startup", function(cmd)
  log.info("handling", cmd)
end)
