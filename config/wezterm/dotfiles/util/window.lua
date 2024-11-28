local wezterm = require("wezterm")

local M = {}

-- https://wezfurlong.org/wezterm/config/lua/window-events
---@type WindowEvent[]
M.events = {
  "augment-command-palette",
  "bell",
  "format-tab-title",
  "format-window-title",
  "new-tab-button-click",
  "open-uri",
  "update-right-status",
  "update-status",
  "user-var-changed",
  "window-config-reloaded",
  "window-focus-changed",
  "window-resized",
}

M.on = {}
do
  local function on_event_fn(event)
    return function(handler)
      wezterm.on(event, handler)
    end
  end
  M.on.augment_command_palette = on_event_fn("augment-command-palette")
  M.on.bell = on_event_fn("bell")
  M.on.format_tab_title = on_event_fn("format-tab-title")
  M.on.format_window_title = on_event_fn("format-window-title")
  M.on.new_tab_button_click = on_event_fn("new-tab-button-click")
  M.on.open_uri = on_event_fn("open-uri")
  M.on.update_right_status = on_event_fn("update-right-status")
  M.on.update_status = on_event_fn("update-status")
  M.on.user_var_changed = on_event_fn("user-var-changed")
  M.on.window_config_reloaded = on_event_fn("window-config-reloaded")
  M.on.window_focus_changed = on_event_fn("window-focus-changed")
  M.on.window_resized = on_event_fn("window-resized")
end

return M
