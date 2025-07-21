local wezterm = require("wezterm")

local action = require("dotfiles.action")

local function join_mods(mods)
  return table.concat(mods, "|")
end

local NONE = [[NONE]]
local CTRL = [[CTRL]]
local SHIFT = [[SHIFT]]
local LEADER = [[LEADER]]
local SUPER = [[SUPER]]
local MOD = join_mods({ CTRL, SHIFT })
local SHIFT_SUPER = join_mods({ SHIFT, SUPER })
local SHIFT_LEADER = join_mods({ SHIFT, LEADER })

local M = {
  NONE = NONE,
  SHIFT = SHIFT,
  SUPER = SUPER,
  LEADER = LEADER,
  MOD = MOD,
}

---@alias KeySpec Key|[string, string, KeyAssignment]

---@param config Config
---@return Config
function M.apply_to_config(config)
  config.debug_key_events = "1" == os.getenv("WEZTERM_DEBUG_KEY_EVENTS")
  config.disable_default_key_bindings = true
  config.enable_kitty_keyboard = true
  config.enable_csi_u_key_encoding = false
  config.keys = config.keys or {}
  config.key_tables = config.key_tables or {}
  config.leader = {
    mods = MOD,
    key = "Space",
    timeout_milliseconds = math.maxinteger,
  }

  local bindings = {
    { MOD, "H", action.activate_direction("Left") },
    { MOD, "J", action.activate_direction("Down") },
    { MOD, "K", action.activate_direction("Up") },
    { MOD, "L", action.activate_direction("Right") },
    { MOD, "DownArrow", wezterm.action.AdjustPaneSize({ "Down", 5 }) },
    { MOD, "LeftArrow", wezterm.action.AdjustPaneSize({ "Left", 5 }) },
    { MOD, "RightArrow", wezterm.action.AdjustPaneSize({ "Right", 5 }) },
    { MOD, "UpArrow", wezterm.action.AdjustPaneSize({ "Up", 5 }) },
    { MOD, "W", wezterm.action.CloseCurrentPane({ confirm = true }) },
    { SUPER, "w", wezterm.action.CloseCurrentPane({ confirm = false }) },
    { SUPER, "q", action.quit_input_selector },
    { MOD, "Enter", action.split_pane() },
    { MOD, "R", wezterm.action.RotatePanes("CounterClockwise") },
    { MOD, "S", wezterm.action.PaneSelect({ mode = "SwapWithActive" }) },
    { MOD, "Z", wezterm.action.TogglePaneZoomState },
    { SHIFT_LEADER, "T", action.move_pane_to_new_tab({ activate = true }) },
    { MOD, "B", wezterm.action.PaneSelect({ mode = "MoveToNewWindow" }) },
    { SUPER, "1", wezterm.action.ActivateTab(0) },
    { SUPER, "2", wezterm.action.ActivateTab(1) },
    { SUPER, "3", wezterm.action.ActivateTab(2) },
    { SUPER, "4", wezterm.action.ActivateTab(3) },
    { SUPER, "5", wezterm.action.ActivateTab(4) },
    { SUPER, "6", wezterm.action.ActivateTab(5) },
    { SUPER, "7", wezterm.action.ActivateTab(6) },
    { SUPER, "8", wezterm.action.ActivateTab(7) },
    { SUPER, "9", wezterm.action.ActivateTab(8) },
    { SUPER, "0", wezterm.action.ActivateTab(9) },
    { MOD, "T", wezterm.action.SpawnTab("CurrentPaneDomain") },
    { MOD, "<", wezterm.action.MoveTabRelative(-1) },
    { MOD, ">", wezterm.action.MoveTabRelative(1) },
    { MOD, "{", wezterm.action.ActivateTabRelative(-1) },
    { MOD, "}", wezterm.action.ActivateTabRelative(1) },
    { [[CTRL]], "Tab", wezterm.action.ActivateTabRelative(1) },
    { [[CTRL|SHIFT]], "Tab", wezterm.action.ActivateTabRelative(-1) },
    { SUPER, "n", wezterm.action.SpawnWindow },
    { SUPER, "PageDown", wezterm.action.ToggleAlwaysOnBottom },
    { SUPER, "PageUp", wezterm.action.ToggleAlwaysOnTop },
    -- TODO use global justfile
    { MOD, "&", action.just({ args = { "--choose" } }) },
    { MOD, "9", wezterm.action.SwitchWorkspaceRelative(-1) },
    { MOD, "0", wezterm.action.SwitchWorkspaceRelative(1) },
    { LEADER, "?", wezterm.action.ShowLauncherArgs({ flags = "FUZZY|KEY_ASSIGNMENTS" }) },
    { LEADER, ".", action.rename_workspace },
    { LEADER, ",", action.rename_tab },
    { LEADER, "p", action.switch_workspace },
    { MOD, "c", wezterm.action.CopyTo("Clipboard") },
    { MOD, "v", wezterm.action.PasteFrom("Clipboard") },
    { LEADER, "v", wezterm.action.ActivateCopyMode },
    { MOD, "F", wezterm.action.QuickSelect },
    { MOD, "E", action.quick_open }, -- https://loganlinn.com
    { MOD, "o", wezterm.action.ActivateCommandPalette },
    { SHIFT_SUPER, "E", action.browse_current_working_dir },
    { MOD, "Home", wezterm.action.ScrollToTop },
    { MOD, "PageDown", wezterm.action.ScrollToPrompt(1) },
    { MOD, "PageUp", wezterm.action.ScrollToPrompt(0) },
    { MOD, "End", wezterm.action.ScrollToBottom },
    { SUPER, "f", wezterm.action.Search({ CaseSensitiveString = "" }) },
    { SHIFT_SUPER, "0", wezterm.action.ResetFontSize },
    { SHIFT_SUPER, "-", wezterm.action.DecreaseFontSize },
    { SHIFT_SUPER, "=", wezterm.action.IncreaseFontSize },
    { SUPER, "DownArrow", wezterm.action.AdjustPaneSize({ "Down", 15 }) },
    { SUPER, "UpArrow", wezterm.action.AdjustPaneSize({ "Up", 15 }) },
    { SUPER, "Home", wezterm.action.ScrollToTop },
    { SUPER, "PageDown", wezterm.action.ScrollByPage(1) },
    { SUPER, "PageUp", wezterm.action.ScrollByPage(-1) },
    { SUPER, "End", wezterm.action.ScrollToBottom },
    { SUPER, "UpArrow", wezterm.action.ScrollToPrompt(-1) },
    { SUPER, "DownArrow", wezterm.action.ScrollToPrompt(1) },
    { LEADER, "q", wezterm.action.QuitApplication },
    { LEADER, ":", wezterm.action.ShowDebugOverlay },
    {
      SUPER,
      "F2",
      wezterm.action.SpawnCommandInNewTab({
        args = { "zsh", "-c", [[
        trap 'echo "Quit"; exit 0' INT
        hs -A
      ]] },
      }),
    },
    { SUPER, "F3", action.show_config },
    {
      SUPER,
      "F5",
      wezterm.action.Multiple({
        wezterm.action.ReloadConfiguration,
        wezterm.action_callback(function(window, pane)
          -- TODO show visual notification
        end),
      }),
    },
    { SUPER, "F6", action.debug_window },
    { SUPER, "F7", action.debug_pane },
    { SUPER, "F8", action.debug_globals },
    -- { SUPER, "F9", action.toggle_debug_key_events },
    -- { SUPER, "F10" },

    { LEADER, "h", wezterm.action.SplitPane({ direction = "Left", size = { Cells = 100 } }) },
    { LEADER, "j", wezterm.action.SplitPane({ direction = "Down", size = { Cells = 20 } }) },
    { LEADER, "k", wezterm.action.SplitPane({ direction = "Up", size = { Cells = 20 } }) },
    { LEADER, "l", wezterm.action.SplitPane({ direction = "Right", size = { Cells = 100 } }) },

    { MOD, "p", wezterm.action.ActivateKeyTable({ name = "Select" }) },
    Select = {
      { NONE, "e", action.quick_open },
      { NONE, "f", wezterm.action.QuickSelect },
      {
        NONE,
        "l",
        wezterm.action.QuickSelectArgs({
          patterns = {
            -- TODO strip shell prompt and styling
            "^(?!\\s*$).+$", -- non-empty line
          },
        }),
      },
    },

    { LEADER, "i", wezterm.action.ActivateKeyTable({ name = "Insert" }) },
    Insert = {
      { NONE, "u", wezterm.action.CharSelect },
      { NONE, "p", wezterm.action.PasteFrom("Clipboard") },
      M.key_assignment({ SHIFT, "P", wezterm.action.PasteFrom("PrimarySelection") }),
    },

    { MOD, [[|]], wezterm.action.ActivateKeyTable({ name = "Split" }) },
    Split = {
      { NONE, "h", wezterm.action.SplitPane({ top_level = true, direction = "Left" }) },
      { NONE, "j", wezterm.action.SplitPane({ top_level = true, direction = "Down" }) },
      { NONE, "k", wezterm.action.SplitPane({ top_level = true, direction = "Up" }) },
      { NONE, "l", wezterm.action.SplitPane({ top_level = true, direction = "Right" }) },
    },
  }
  for i = 1, 8 do
    table.insert(bindings, {
      key = tostring(i),
      mods = MOD,
      action = wezterm.action.ActivateWindow(i - 1),
    })
  end

  M.bind(config, bindings)

  -- Mouse bindings
  if wezterm.gui then
    config.mouse_bindings = config.mouse_bindings or {}
    table.insert(config.mouse_bindings, {
      event = { Up = { streak = 1, button = "Left" } },
      mods = SUPER,
      action = wezterm.action.OpenLinkAtMouseCursor,
    })
    table.insert(config.mouse_bindings, {
      event = { Up = { streak = 1, button = "Middle" } },
      mods = NONE,
      action = wezterm.action.OpenLinkAtMouseCursor,
    })
  end

  return config
end

---@param key KeySpec
---@return Key
function M.key_assignment(key)
  if key[1] then
    assert(key.mods == nil)
    key.mods = key[1]
    key[1] = nil
  end
  if key[2] then
    assert(key.key == nil)
    key.key = tostring(key[2])
    key[2] = nil
  end
  if key[3] then
    assert(key.action == nil)
    key.action = key[3]
    key[3] = nil
  end
  return key
end

---@param config Config
---@param name? string
---@return Key[]
function M.get_key_table(config, name)
  if not name then
    config.keys = config.keys or {}
    return config.keys
  else
    config.key_tables = config.key_tables or {}
    config.key_tables[name] = config.key_tables[name] or {}
    return config.key_tables[name]
  end
end

---@param config Config
---@param keys_spec table<string|number, KeySpec|KeySpec[]>
---@return Config
function M.bind(config, keys_spec, key_table)
  if type(key_table) ~= "table" then
    key_table = M.get_key_table(config, key_table)
  end
  for k, v in pairs(keys_spec) do
    if type(k) == "number" then
      local ka = M.key_assignment(v)
      if ka.action then
        table.insert(key_table, ka)
      end
    elseif type(k) == "string" then
      M.bind(config, v, k)
    end
  end
  return config
end

return M
