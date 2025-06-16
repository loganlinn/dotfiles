local M = {}

M.apply_to_config = function(config)
  local modules = {
    require("dotfiles.event.mux-startup"),
    require("dotfiles.event.gui-startup"),
    require("dotfiles.event.gui-attached"),
    require("dotfiles.event.user-var-changed"),
    require("dotfiles.event.window-focus-changed"),
    require("dotfiles.event.window-config-reloaded"),
    require("dotfiles.event.open-uri"),
  }

  for _, mod in pairs(modules) do
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
