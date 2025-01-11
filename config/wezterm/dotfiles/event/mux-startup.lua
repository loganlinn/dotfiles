local wezterm = require("wezterm")
local util = require("dotfiles.util")
local log = require("dotfiles.util.logger").new("dotfiles.event.mux-startup")

-- https://wezfurlong.org/wezterm/config/lua/mux-events/mux-startup.html
wezterm.on("mux-startup", function()
  log.info("handling")
end)
