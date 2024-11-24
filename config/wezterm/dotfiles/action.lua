local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local log = wezterm.log_info
local is = require("dotfiles.util.is")

---@class dotfiles.action : wezterm.action
local M = {}

---@param callback fun(window: wezterm.Window, pane: wezterm.Pane, ...): wezterm.KeyAssignment
M.callback = function(callback)
  return wezterm.action_callback(callback)
end

M.SimplePromptInputLine = function(description, callback)
  return act.PromptInputLine({
    description = wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { AnsiColor = "Fuchsia" } },
      { Text = description },
      "ResetAttributes",
    }),
    action = M.callback(function(window, pane, input, ...)
      if input ~= nil and input ~= "" then
        callback(window, pane, input, ...)
      else
        log("Skipping action because input is empty")
      end
    end),
  })
end

M.RenameTab = M.SimplePromptInputLine("Tab name:", function(window, _, input)
  window:active_tab():set_title(input)
end)

M.RenameWorkspace = M.SimplePromptInputLine("Workspace name:", function(_, _, input)
  mux.rename_workspace(mux.get_active_workspace(), input)
end)

M.SwitchToNamedWorkspace = M.SimplePromptInputLine("Workspace name:", function(window, pane, name)
  window:perform_action(act.SwitchToWorkspace({ name = name }), pane)
end)

M.ActivateRightPane = M.callback(function(window, pane)
  local tab = window:active_tab()
  log("pane info", tab:panes_with_info())

  -- local panes = tab:panes()
  -- local sidepane = pane:split({
  --   direction = "Right",
  --   size = 0.3,
  --   top_level = true,
  -- })
  -- sidepane:activate()
end)

M.AdjustPaneSizeSmart = function(size)
  assert(is.number(size))
  return M.callback(function(window, pane)
    local config = window:effective_config()
    local dimensions = pane:get_dimensions()
    local direction
    if (dimensions.cols or 0) > (dimensions.viewport_rows or 0) then
      direction = "Right"
    else
      direction = "Down"
    end
    print("AdjustPaneSizeSmart", direction, size)
    -- window:perform_action(M.AdjustPaneSize({ direction, size }), pane)
  end)
end

---@param ... string
M.SpawnDotfilesCommandInNewTab = function(...)
  return act.SpawnCommandInNewTab({
    args = { "dotfiles", ... },
  })
end

M.InputSelectorDemo = act.InputSelector({
  action = wezterm.action_callback(function(window, pane, id, label)
    if not id and not label then
      wezterm.log_info("cancelled")
    else
      wezterm.log_info("you selected ", id, label)
      pane:send_text(id)
    end
  end),
  title = "I am title",
  choices = {
    -- This is the first entry
    {
      -- Here we're using wezterm.format to color the text.
      -- You can just use a string directly if you don't want
      -- to control the colors
      label = wezterm.format({
        { Foreground = { AnsiColor = "Red" } },
        { Text = "No" },
        { Foreground = { AnsiColor = "Green" } },
        { Text = " thanks" },
      }),
      -- This is the text that we'll send to the terminal when
      -- this entry is selected
      id = "Regretfully, I decline this offer.",
    },
    -- This is the second entry
    {
      label = "WTF?",
      id = "An interesting idea, but I have some questions about it.",
    },
    -- This is the third entry
    {
      label = "LGTM",
      id = "This sounds like the right choice",
    },
  },
})

-- proxy standard wezterm.action interface convenience/being single source of truth for actions
setmetatable(M, { __index = act })

return M
