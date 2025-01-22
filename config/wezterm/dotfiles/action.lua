local wezterm = require("wezterm")
local patterns = require("dotfiles.patterns")
local util = require("dotfiles.util")
local log = require("dotfiles.util.logger")("action.lua")

local M = {}

local SHELL = os.getenv("SHELL") or "zsh"

---@return string[]
local function shell_args(command, options)
  local args = { options.shell or SHELL }
  if options.login ~= false then
    table.insert(args, "-l")
  end
  if options.interactive then
    table.insert(args, "-i")
  end
  if command ~= nil then
    if type(command) ~= "string" then
      command = wezterm.shell_join_args(command)
    end
    table.insert(args, "-c")
    table.insert(args, command)
    table.insert(args, SHELL)
    for _, arg in ipairs(options.args or {}) do
      if type(arg) == "string" then
        table.insert(args, arg)
      elseif type(arg) == "table" then
        for _, v in ipairs(arg) do
          table.insert(args, tostring(v))
        end
      elseif arg ~= nil then
        error("expected string or table, got: " .. type(arg))
      end
    end
  end
  return args
end

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

local function with_user_var_envs(env_vars, user_vars)
  env_vars = env_vars or {}
  for name, value in pairs(user_vars) do
    env_vars["WEZTERM_USER_VAR_" .. name] = tostring(value)
  end
  return env_vars
end

local function set_zoomed(tab, enable)
  -- don't zoom when there's no effect
  if enable and next(tab:panes()) ~= nil then
    tab:set_zoomed(true)
  else
    tab:set_zoomed(false)
  end
end

---@param window Window
---@param pane Pane
---@param spawn_args? {direction: Direction, top_level: boolean, size: number, args?: string[], set_environment_variables?: {[string]: string}}
---@return Pane popup_pane
local function spawn_popup(window, pane, spawn_args)
  pane = pane or window:active_tab():active_pane()
  spawn_args = spawn_args or {}
  spawn_args.direction = spawn_args.direction or POPUP_DIRECTION
  spawn_args.top_level = spawn_args.top_level or true
  spawn_args.size = spawn_args.size or 0.333
  spawn_args.args = spawn_args.args or { SHELL, "-l" }
  spawn_args.set_environment_variables = with_user_var_envs(spawn_args.set_environment_variables or {}, {
    PANE_ROLE = PANE_ROLE_POPUP,
    PANE_ID_ORIGIN = tostring(pane:pane_id()),
  })

  -- cannot spawn from zoomed pane
  set_zoomed(pane:tab(), false)

  log.info("splitting", pane, spawn_args)
  local new_pane = pane:split(spawn_args)

  activate_pane(window, new_pane, pane)
  return new_pane
end

local function open_popup(window, pane, spawn_args)
  local popup = pane:tab():get_pane_direction(spawn_args.direction or POPUP_DIRECTION)
  if popup then
    popup:activate()
  else
    spawn_popup(window, pane, spawn_args)
  end
end

local function is_same_pane(pane, other)
  return pane:pane_id() == other:pane_id()
end

M.toggle_popup_pane = wezterm.action_callback(function(window, pane)
  local direction = POPUP_DIRECTION
  local tab = window:active_tab()
  local panes_with_info = tab:panes_with_info()
  local is_primary = tab:get_pane_direction(OPPOSITE_DIRECTION[direction]) == nil

  if is_primary then
    open_popup(window, pane, { direction = direction })
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
    local target_pane = tab:get_pane_direction(direction)
    if target_pane then
      activate_pane(window, target_pane, pane)
    elseif is_same_pane(pane, panes[1]) then
      if direction == POPUP_DIRECTION or #panes == 1 then
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

local format_prompt_description = function(description)
  return wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { AnsiColor = "Fuchsia" } },
    { Text = description },
    "ResetAttributes",
  })
end

M.rename_tab = wezterm.action_callback(function(window, pane)
  window:perform_action(
    wezterm.action.PromptInputLine({
      description = format_prompt_description("Rename tab:"),
      initial_value = window:active_tab():get_title(),
      action = wezterm.action_callback(function(window, _, input)
        if input and input ~= "" then
          window:active_tab():set_title(input)
        end
      end),
    }),
    pane
  )
end)

M.rename_workspace = wezterm.action.PromptInputLine({
  description = format_prompt_description("Rename workspace:"),
  initial_value = wezterm.mux.get_active_workspace(),
  action = wezterm.action_callback(function(_, _, input)
    if input and input ~= "" then
      wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), input)
    end
  end),
})

M.debug_window = wezterm.action_callback(function(window, _)
  local m = require("dotfiles.util.debug")
  m.inspect(window, m.dump_window(window), tostring(window))
end)

M.debug_pane = wezterm.action_callback(function(window, pane)
  local m = require("dotfiles.util.debug")
  m.inspect(window, m.dump_pane(pane), tostring(pane))
end)

M.show_config = wezterm.action_callback(function(window, _)
  local m = require("dotfiles.util.debug")
  m.inspect(window, window:effective_config(), tostring(window) .. ".effective_config")
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

M.quit_input_selector = wezterm.action.InputSelector({
  fuzzy = true,
  title = wezterm.format({
    { Foreground = { AnsiColor = "Red" } },
    { Text = "Danger Zone" },
  }),
  choices = {
    {
      id = "CloseCurrentTab",
      label = wezterm.format({
        { Text = "TAB" },
      }),
    },
    {
      id = "QuitApplication",
      label = wezterm.format({
        { Text = "APPLICATION" },
      }),
    },
  },
  action = wezterm.action_callback(function(window, pane, id, label)
    local action
    if id == "CloseCurrentPane" then
      action = wezterm.action.CloseCurrentPane({ confirm = false })
    elseif id == "CloseCurrentTab" then
      action = wezterm.action.CloseCurrentTab({ confirm = false })
    elseif id == "QuitApplication" then
      action = wezterm.action.QuitApplication
    end
    if action then
      log.info("Performing action for selected input", id, label, action)
      window:perform_action(action, pane)
    else
      log.debug("No action found for selected input")
    end
  end),
})

M.just = function(options)
  local direction = options.direction or "Bottom"
  local size = options.size or 0.3
  local cwd = options.cwd
  local args = shell_args(
    [[
      if ! just "$@"; then
        echo Exited with "$?" status
      fi
      read -s -k '?Press any key to continue.'
    ]],
    { interactive = true, args = options.args }
  )
  return wezterm.action_callback(function(window, pane)
    pane:split(log.info({
      direction = direction,
      cwd = cwd,
      args = args,
      size = size,
    }))
  end)
end

return M
