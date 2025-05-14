local M = {}

M.apply_to_config = function(config)
  for _, modname in pairs({
    "dotfiles.event.mux-startup",
    "dotfiles.event.gui-startup",
    "dotfiles.event.gui-attached",
    "dotfiles.event.user-var-changed",
    "dotfiles.event.window-focus-changed",
    "dotfiles.event.window-config-reloaded",
    "dotfiles.event.open-uri",
  }) do
    local mod = require(modname)
    if type(mod) == "table" and mod.apply_to_config then
      mod.apply_to_config(config)
    end
  end

  -- prevent duplicate registration
  M.apply_to_config = function()
    error("event handlers already registered")
  end
end

return M
