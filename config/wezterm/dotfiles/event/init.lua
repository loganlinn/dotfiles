local M = {}

M.apply_to_config = function(config)
  local wezterm = require("wezterm")
  for _, event in pairs({
    "mux-startup",
    "gui-startup",
    "user-var-changed",
    "window-focus-changed",
    "window-config-reloaded",
    "open-uri",
  }) do
    local mod_name = "dotfiles.event." .. event
    wezterm.log_info("loading:", mod_name)
    local mod = require(mod_name)
    if type(mod) == "table" and mod.apply_to_config then
      mod.apply_to_config(config)
    end
  end
  M.apply_to_config = function()
    error("event handlers already registered")
  end
end

return M
