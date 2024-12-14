local wezterm = require("wezterm")

---@param tab TabInformation
---@param pane PaneInformation
---@param tabs TabInformation[]
---@param panes PaneInformation[]
---@param config Config
---@return string
return function(tab, pane, tabs, panes, config)
  local window = wezterm.mux.get_window(tab.window_id) ---@type MuxWindow
  local title = window:get_workspace()
  title = title .. ": " .. tab.active_pane.title
  title = title .. "[" .. window:window_id() .. ":" .. tab.tab_id .. ":" .. pane.pane_id .. "]"
  if tab.active_pane.is_zoomed then
    title = title .. ":Z"
  end
  return title
end
