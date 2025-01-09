local wezterm = require("wezterm")
local patterns = require("dotfiles.patterns")
local util = require("dotfiles.util")
local log = require("dotfiles.util.logger")("action.lua")

local M = {}

setmetatable(M, {
  __index = function(t, k)
    return rawget(t, k) or wezterm.action[k] -- will error if not found
  end,
  __newindex = function(t, k, v)
    if rawget(t, k) or wezterm.has_action(k) then
      error("attempt to override existing action: " .. tostring(k))
    end
    rawset(t, k, v)
  end,
})

local ACTIVATE_PANE_EVENT = "activate-pane"
local ACTIVATE_TAB_EVENT = "activate-tab"
local PANE_ROLE_POPUP = "Popup"
local OPPOSITE_DIRECTION = setmetatable({
  Left = "Right",
  Right = "Left",
  Up = "Down",
  Down = "Up",
  Bottom = "Top",
  Top = "Bottom",
}, {
  __index = function(_, k)
    error("invalid direction: " .. tostring(k))
  end,
})
local POPUP_DIRECTION = "Right"

local function activate_pane(window, pane, from_pane)
  assert(pane and pane.pane_id and pane.activate)
  wezterm.emit(ACTIVATE_PANE_EVENT, window, pane, from_pane)
  return pane:activate()
end

local function activate_tab(window, tab, from_pane)
  assert(tab and tab.tab_id and tab.activate)
  wezterm.emit(ACTIVATE_TAB_EVENT, window, tab, from_pane)
  return tab:activate()
end

local function with_user_var_envs(env_vars, user_vars)
  env_vars = env_vars or {}
  for name, value in pairs(user_vars) do
    env_vars["WEZTERM_USER_VAR_" .. name] = tostring(value)
  end
  return env_vars
end

---@param window Window
---@param from_pane Pane
---@param spawn_args? {direction: Direction, top_level: boolean, size: number, args?: string[], set_environment_variables?: {[string]: string}}
---@return Pane popup_pane
local function spawn_popup(window, from_pane, spawn_args)
  -- cannot spawn from zoomed pane
  from_pane:tab():set_zoomed(false)
  spawn_args = spawn_args or {
    direction = POPUP_DIRECTION,
    top_level = true,
    size = 0.333,
  }
  spawn_args.args = spawn_args.args or { "zsh", "-l" }
  spawn_args.set_environment_variables = with_user_var_envs(spawn_args.set_environment_variables or {}, {
    PANE_ROLE = PANE_ROLE_POPUP,
    PANE_ID_ORIGIN = tostring(from_pane:pane_id()),
  })

  local new_pane = from_pane:split(log.info(spawn_args))
  activate_pane(window, new_pane, from_pane)
  return new_pane
end

local function open_popup(window, pane, spawn_args)
  local popup = pane:tab():get_pane_direction(POPUP_DIRECTION)
  if popup then
    popup:activate()
  else
    spawn_popup(window, pane)
  end
end

local function is_popup_pane(pane)
  return pane:get_user_vars().PANE_ROLE == PANE_ROLE_POPUP
end

local function is_origin_pane(pane, other)
  return pane:get_user_vars().PANE_ID_ORIGIN == tostring(other:pane_id())
end

local function is_same_pane(pane, other)
  return pane:pane_id() == other:pane_id()
end

---@param tab MuxTab
---@return Pane[]
local function find_popups(tab)
  assert(tab.panes)
  local results = {}
  for _, pane in pairs(tab:panes()) do
    if is_popup_pane(pane) then
      table.insert(results, pane)
    end
  end
  return results
end

local function set_zoomed(tab, enable)
  -- don't zoom when there's no effect
  if enable and next(tab:panes()) ~= nil then
    tab:set_zoomed(true)
  else
    tab:set_zoomed(false)
  end
end

M.toggle_popup_pane = wezterm.action_callback(function(window, pane)
  local tab = window:active_tab()
  local panes_with_info = tab:panes_with_info()
  -- local primary = find_primary_pane(panes_with_info) or error()
  local is_primary = tab:get_pane_direction(OPPOSITE_DIRECTION[POPUP_DIRECTION]) == nil
  -- local _, pane_info = find_active(panes_with_info)

  if is_primary then
    open_popup(window, pane)
  else
    activate_pane(window, panes_with_info[1].pane, pane)
    set_zoomed(tab, true)
  end
end)

---@param direction Direction
M.activate_direction = function(direction)
  return wezterm.action_callback(function(window, pane)
    local tab = pane:tab() or window:active_tab()
    local panes = tab:panes()
    local direction_pane = tab:get_pane_direction(direction)
    if direction_pane then
      activate_pane(window, direction_pane, pane)
    elseif is_same_pane(pane, panes[1]) then
      if direction == "Right" or #panes == 1 then
        spawn_popup(window, pane)
      elseif direction == "Left" then
        activate_pane(window, tab:get_pane_direction("Prev"), pane)
      end
    else
      activate_pane(window, panes[1], pane)
      set_zoomed(tab, true)
    end
  end)
end

M.prompt_input_callback = function(description, callback)
  return wezterm.action.PromptInputLine({
    description = wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { AnsiColor = "Fuchsia" } },
      { Text = description },
      "ResetAttributes",
    }),
    action = wezterm.action_callback(function(window, pane, input, ...)
      if input ~= nil and input ~= "" then
        callback(window, pane, input, ...)
      else
        wezterm.log_info("Skipping action because input is empty")
      end
    end),
  })
end

M.RenameTab = M.prompt_input_callback("Tab title:", function(window, _, title)
  window:active_tab():set_title(title)
end)

M.RenameWorkspace = M.prompt_input_callback("Workspace name:", function(_, _, name)
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

M.debug_window = wezterm.action_callback(function(window, _)
  local m = require("dotfiles.util.debug")
  m.inspect(window, m.dump_window(window), tostring(window))
end)

M.debug_pane = wezterm.action_callback(function(window, pane)
  local m = require("dotfiles.util.debug")
  m.inspect(window, m.dump_pane(pane), tostring(pane))
end)

M.split_pane = function(args)
  args = args or {}

  return wezterm.action_callback(function(_, pane)
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

M.move_pane_to_new_tab = function(opts)
  opts = opts or {}
  return wezterm.action_callback(function(_, pane)
    local tab = pane:move_to_new_tab()
    if opts.activate then
      tab:activate()
    end
  end)
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
    return wezterm.action_callback(function(window, _)
      window:set_config_overrides(param(window:get_config_overrides()))
    end)
  elseif type(param) == "table" then
    return wezterm.action_callback(function(window, _)
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

M.toggle_debug_key_events = wezterm.action_callback(function(window, _)
  apply_to_config_overrides(function(overrides)
    overrides = overrides or {}
    overrides.debug_key_events = not overrides.debug_key_events
    return overrides
  end, window)
end)

-- Open either URLs or paths
M.quick_open = wezterm.action.QuickSelectArgs({
  patterns = patterns.union(patterns.FILE, patterns.URL),
  action = wezterm.action_callback(function(window, pane)
    local selection = window:get_selection_text_for_pane(pane)
    window:perform_action(wezterm.action.ClearSelection, pane)
    if selection then
      log.info("quick_open:", selection)
      local uri
      if pcall(wezterm.url.parse, selection) then
        uri = selection
      else
        if string.match(selection, "^/") then
          uri = "file://" .. selection
        else
          uri = "file://" .. pane:get_current_working_dir().file_path .. selection
        end
      end
      log.info("opening", uri)
      wezterm.emit("open-uri", window, pane, uri)
      -- wezterm.open_with(uri)
    end
  end),
})

M.switch_workspace = wezterm.action_callback(function(window, pane)
  -- TODO generate, cache complete list
  local workspaces = {
    {
      id = wezterm.home_dir .. "/.dotfiles",
      label = "loganlinn/dotfiles",
    },
    {
      id = wezterm.home_dir .. "/src/github.com/gamma-app/gamma",
      label = "gamma-app/gamma",
    },
  }

  window:perform_action(
    wezterm.action.InputSelector({
      title = "Switch to workspace",
      choices = workspaces,
      fuzzy = true,
      action = wezterm.action_callback(function(inner_window, inner_pane, choice_id, choice_label)
        if not choice_id and not choice_label then
          log.info("input selector cancelled")
          return
        end
        inner_window:perform_action(wezterm.action.SwitchToWorkspace({
          name = choice_label,
          spawn = {
            label = "Workspace: " .. choice_label,
            cwd = choice_id,
          },
        }, inner_pane))
      end),
    }),
    pane
  )
end)

M.browse_current_working_dir = wezterm.action_callback(function(window, pane)
  local application = nil
  if util.is_darwin() then
    application = "Finder"
  end
  log.info("opening ", pane:get_current_working_dir())
  wezterm.open_with(tostring(pane:get_current_working_dir() or wezterm.home_dir), application)
end)

return M
