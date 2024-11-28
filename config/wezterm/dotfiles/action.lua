local wezterm = require("wezterm")

local custom_action = {}

---@class dotfiles.action : table<KeyAssignment, any>
local M = setmetatable({}, {
  __index = function(_, k)
    local action = custom_action[k]
    if action then
      return action
    end
    return wezterm.action[k] -- will error if not found
  end,
  __newindex = function(t, k, v)
    if custom_action[k] or wezterm.has_action(k) then
      error("attempt to override existing action: " .. tostring(k))
    end
    rawset(custom_action, k, v)
  end,
})

local function update_config_overrides(window, update)
  local overrides = window:get_config_overrides() or {}
  overrides = update(overrides) or overrides
  wezterm.log_info("window.config_overrides", window, overrides)
  window:set_config_overrides(overrides)
  return overrides
end

local function inspect_window(window) end

--- Creates callback action
---@param fn fun(window: Window, pane: Pane, ...): any
M.fn = function(fn)
  return wezterm.action_callback(fn)
end

M.PromptInputLineSimple = function(description, callback)
  return M.PromptInputLine({
    description = wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { AnsiColor = "Fuchsia" } },
      { Text = description },
      "ResetAttributes",
    }),
    action = M.fn(function(window, pane, input, ...)
      if input ~= nil and input ~= "" then
        callback(window, pane, input, ...)
      else
        wezterm.log_info("Skipping action because input is empty")
      end
    end),
  })
end

M.RenameTab = M.PromptInputLineSimple("Tab title:", function(window, _, title)
  window:active_tab():set_title(title)
end)

M.RenameWorkspace = M.PromptInputLineSimple("Workspace name:", function(_, _, name)
  wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), name)
end)

M.SwitchToNamedWorkspace = M.PromptInputLineSimple("Workspace name:", function(window, pane, name)
  window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), pane)
end)

M.DumpWindow = M.fn(function(window, _)
  local data = require("dotfiles.util.debug").dump_window(window)

  wezterm.log_info(data)

  local json_encode
  if wezterm.serde then
    json_encode = wezterm.serde.json_encode_pretty
  end
  json_encode = json_encode or wezterm.json_encode

  window:mux_window():spawn_tab({
    args = { "zsh", "-l", "-c", [[ jless <<<"$1" || true ]], "-s", json_encode(data) },
  })
end)

M.SplitPaneAuto = function(args)
  args = args or {}

  return M.fn(function(window, pane)
    local pane_dimensions = pane:get_dimensions()
    if 0.6 > ((pane_dimensions.pixel_height or 1) / (pane_dimensions.pixel_width or 1)) then
      args.direction = "Right"
    else
      args.direction = "Bottom"
    end
    local new_pane = pane:split(args)
    new_pane:activate()
  end)
end

M.ActivateRightPane = M.fn(function(window, pane)
  local tab = window:active_tab()
  local panes = tab:panes()

  -- local sidepane = pane:split({
  --   direction = "Right",
  --   size = 0.3,
  --   top_level = true,
  -- })
  -- sidepane:activate()
end)

M.MovePaneToNewTab = M.fn(function(_, pane)
  pane:move_to_new_tab()
end)

---@param workspace? string
M.MovePaneToWorkspace = function(workspace)
  if workspace then
    M.fn(function(_, pane)
      pane:move_to_new_tab()
    end)
  else
    M.PromptInputLineSimple("Workspace name:", function(_, _, name)
      wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), name)
    end)
  end
end

M.ToggleDebugKeyEvents = M.fn(function(window, _)
  update_config_overrides(window, function(overrides)
    overrides.debug_key_events = not overrides.debug_key_events
    return overrides
  end)
end)

M.InputSelectorDemo = M.InputSelector({
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

return M
