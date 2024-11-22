local wezterm = require("wezterm")
local log_info = wezterm.log_info

local M = setmetatable({}, {
  __index = wezterm.action,
})

local function prompt_input_action_callback(callback)
  return wezterm.action_callback(function(window, pane, input, ...)
    if input ~= nil and input ~= "" then
      callback(window, pane, input, ...)
    end
  end)
end

M.RenameTab = wezterm.action.PromptInputLine({
  description = wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Text = "Tab name:" },
  }),
  action = prompt_input_action_callback(function(window, _, input)
    window:active_tab():set_title(input)
  end),
})

M.RenameWorkspace = wezterm.action.PromptInputLine({
  -- initial_value = wezterm.mux.get_active_workspace(),
  description = wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Text = "Workspace name:" },
  }),
  action = prompt_input_action_callback(function(window, _, input)
    wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), input)
  end),
})

M.SwitchToNamedWorkspace = wezterm.action.PromptInputLine({
  description = wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Text = "Workspace name:" },
  }),
  action = prompt_input_action_callback(function(window, pane, name)
    window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), pane)
  end),
})

M.ActivateRightPane = wezterm.action_callback(function(window, pane)
  local tab = window:active_tab()
  wezterm.log_info("pane info", tab:panes_with_info())

  -- local panes = tab:panes()
  -- local sidepane = pane:split({
  --   direction = "Right",
  --   size = 0.3,
  --   top_level = true,
  -- })
  -- sidepane:activate()
end)

return M
