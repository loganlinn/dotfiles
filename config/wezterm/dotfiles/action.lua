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

local action_callback = wezterm.action_callback

---@generic T : {is_active: boolean}
---@param infos T[]
---@return T
local function find_active(infos)
  for _, info in pairs(infos) do
    if info.is_active then
      return info
    end
  end
end

---@param panes_with_info PaneInformation[]
---@return PaneInformation?
local function find_primary_pane(panes_with_info)
  local max_pane_px = 0 - math.huge
  local max_pane_info
  for _, pane_info in pairs(panes_with_info) do
    local px = pane_info.pixel_width * pane_info.pixel_height
    if px > max_pane_px then
      max_pane_info = pane_info
      max_pane_px = px
    end
  end
  return max_pane_info
end

local function find_edge_panes(panes_with_info, edge)
  local max_pane_px = 0 - math.huge
  local max_pane_info
  for _, pane_info in pairs(panes_with_info) do
    local px = pane_info.pixel_width * pane_info.pixel_height
    if px > max_pane_px then
      max_pane_info = pane_info
      max_pane_px = px
    end
  end
  return max_pane_info
end

M.TogglePopupPane = action_callback(function(window, pane)
  local tab = window:active_tab()
  local panes_with_info = tab:panes_with_info()
  -- local primary = find_primary_pane(panes_with_info) or error()
  local active = find_active(panes_with_info) or error()

  if tab:get_pane_direction("Left") == nil then
    if not active.is_zoomed then
      -- "close" other panes
      tab:set_zoomed(true)
    else
      tab:set_zoomed(false)
      local right = tab:get_pane_direction("Right")
      if right then
        right:activate()
      else
        pane
          :split({
            direction = "Right",
            top_level = true,
            size = 0.333,
          })
          :activate()
      end
    end
  else
    table.sort(panes_with_info, function(a, b)
      return a.index < b.index
    end)
    panes_with_info[1].pane:activate()
    tab:set_zoomed(true)
  end
end)

wezterm.on("activate-pane", function(window, pane, data)
  wezterm.log_info("activate-pane", window, pane, data)
end)

---@param opts Direction|number|{direction: Direction}||{index: number}
M.activate_pane = function(opts)
  local action
  if type(opts) == "string" then
    opts = { direction = opts }
  elseif type(opts) == "number" then
    opts = { index = opts }
  end
  if opts.direction then
    action = wezterm.action.ActivatePaneDirection(opts.direction)
  elseif opts.index then
    action = wezterm.action.ActivatePaneByIndex(opts.index)
  else
    error("options requires one of: direction, index")
  end
  return action_callback(function(window, pane)
    wezterm.emit("activate-pane", window, pane, opts)
    window:perform_action(action, pane)
  end)
end

M.PromptInputLineSimple = function(description, callback)
  return wezterm.action.PromptInputLine({
    description = wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { AnsiColor = "Fuchsia" } },
      { Text = description },
      "ResetAttributes",
    }),
    action = action_callback(function(window, pane, input, ...)
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

-- M.WorkspaceSelector = function(opts)
--   return M.fn(function(window, pane)
--     -- Here you can dynamically construct a longer list if needed
--
--     local home = wezterm.home_dir
--     local workspaces = {
--       { id = home, label = "Home" },
--       { id = home .. "/work", label = "Work" },
--       { id = home .. "/personal", label = "Personal" },
--       { id = home .. "/.config", label = "Config" },
--     }
--
--     window:perform_action(
--       wezterm.action.InputSelector({
--         action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
--           if not id and not label then
--             wezterm.log_info("cancelled")
--           else
--             wezterm.log_info("id = " .. id)
--             wezterm.log_info("label = " .. label)
--             inner_window:perform_action(
--               wezterm.action.SwitchToWorkspace({
--                 name = label,
--                 spawn = {
--                   label = "Workspace: " .. label,
--                   cwd = id,
--                 },
--               }),
--               inner_pane
--             )
--           end
--         end),
--         title = "Choose Workspace",
--         choices = workspaces,
--         fuzzy = true,
--         fuzzy_description = "Fuzzy find and/or make a workspace",
--       }),
--       pane
--     )
--   end)
-- end

M.SwitchToNamedWorkspace = M.PromptInputLineSimple("Workspace name:", function(window, pane, name)
  window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), pane)
end)

M.DumpWindow = action_callback(function(window, _)
  local m = require("dotfiles.util.debug")
  m.inspect(window, m.dump_window(window), tostring(window))
end)

M.DumpPane = action_callback(function(window, pane)
  local m = require("dotfiles.util.debug")
  m.inspect(window, m.dump_pane(pane), tostring(pane))
end)

M.SplitPaneAuto = function(args)
  args = args or {}

  return action_callback(function(_, pane)
    local pane_dimensions = pane:get_dimensions()
    if 0.6 > ((pane_dimensions.pixel_height or 1) / (pane_dimensions.pixel_width or 1)) then
      args.direction = "Right"
    else
      args.direction = "Bottom"
    end
    args.set_environment_variables = {
      WEZTERM_INIT_USER_VAR = "POPUP=Right",
    }
    local new_pane = pane:split(args)
    new_pane:activate()
  end)
end

M.ToggleDockedPane = function(direction)
  return action_callback(function(window, pane)
    local tab = window:active_tab()
    local edge_pane = tab:get_pane_direction(direction)

    -- local sidepane = pane:split({
    --   direction = "Right",
    --   size = 0.3,
    --   top_level = true,
    -- })
    -- sidepane:activate()
  end)
end

M.MovePaneToNewTab = function(opts)
  opts = opts or {}
  return action_callback(function(_, pane)
    local tab = pane:move_to_new_tab()
    if opts.activate then
      tab:activate()
    end
  end)
end

--- FIXME FIXME FIXME FIXME FIXME FIXME
---@param workspace? string
M.MovePaneToWorkspace = function(workspace)
  if workspace then
    action_callback(function(_, pane)
      pane:move_to_new_tab()
    end)
  else
    M.PromptInputLineSimple("Workspace name:", function(_, _, name)
      wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), name)
    end)
  end
end

-- Applies function to current value of window config overrides, then
-- sets configu overrides to returned value.
---@param f fun(current_config_overides: Config|nil): Config|nil
---@param window Window
---@return Config|nil updated
local function apply_to_config_overrides(f, window)
  local result = f(window:get_config_overrides())
  window:set_config_overrides(result)
  return result
end

---@param param
---@param config_key?
M.UpdateConfigOverrides = function(param)
  if type(param) == "function" then
    return action_callback(function(window, _)
      window:set_config_overrides(param(window:get_config_overrides()))
    end)
  elseif type(param) == "table" then
    return action_callback(function(window, _)
      local overrides = window:get_config_overrides() or {}
      for config_key, f in pairs(param) do
        overrides[config_key] = f(overrides[config_key])
      end
      window:set_config_overrides(overrides)
    end)
  else
    error("expected function or table, got: " .. tostring(type(param)))
  end
end

M.ToggleDebugKeyEvents = action_callback(function(window, _)
  apply_to_config_overrides(function(overrides)
    overrides.debug_key_events = not overrides.debug_key_events
    return overrides
  end, window)
end)

M.QuickSelectUrl = wezterm.action.QuickSelectArgs({
  patterns = {
    "[a-zA-Z]+://\\S+",
  },
  action = wezterm.action_callback(function(window, pane)
    local url = window:get_selection_text_for_pane(pane)
    window:perform_action(wezterm.action.ClearSelection, pane)
    if url then
      wezterm.open_with(url)
    end
  end),
})

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
