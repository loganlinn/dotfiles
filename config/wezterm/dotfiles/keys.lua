local wezterm = require("wezterm")
local str = wezterm.to_string
local info, warn = wezterm.log_info, wezterm.log_warn
local lpad, rpad = wezterm.pad_left, wezterm.pad_right
local pad = function(s, n)
  return lpad(rpad(s, n), n)
end

local action = require("dotfiles.action")

local NONE = [[NONE]]
local CTRL = [[CTRL]]
local SHIFT = [[SHIFT]]
local LEADER = [[LEADER]]
local SUPER = [[SUPER]]
local MOD = [[CTRL|SHIFT]]
local SUPER_SHIFT = [[SUPER|SHIFT]]
local LEADER_SHIFT = [[LEADER|SHIFT]]

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
  config.leader = {
    mods = MOD,
    key = "Space",
    timeout_milliseconds = 9223372036854775807,
  }
  config.keys = config.keys or {}
  config.key_tables = config.key_tables or {}

  if wezterm.gui then
    -- Inherit default key tables (e.g. copy_mode, search_mode)
    for k, v in pairs(wezterm.gui.default_key_tables()) do
      config.key_tables[k] = v
    end

    -- Mouse bindings
    config.disable_default_mouse_bindings = false
    config.mouse_bindings = config.mouse_bindings or {}
    table.insert(config.mouse_bindings, {
      mods = SUPER,
      event = { Up = { streak = 1, button = "Left" } },
      action = wezterm.action.OpenLinkAtMouseCursor,
    })
    table.insert(config.mouse_bindings, {
      mods = NONE,
      event = { Up = { streak = 1, button = "Middle" } },
      action = wezterm.action.OpenLinkAtMouseCursor,
    })
    table.insert(config.mouse_bindings, {
      mods = NONE,
      event = { Down = { streak = 4, button = "Left" } },
      action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
    })
  end

  M.bind(config, {
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
    { LEADER_SHIFT, "T", action.move_pane_to_new_tab({ activate = true }) },
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
    { MOD, "!", action.switch_to_workspace_1 },
    { MOD, "@", action.switch_to_workspace_2 },
    { MOD, "#", action.switch_to_workspace_3 },
    { MOD, "$", action.edit_last_output },
    { MOD, "%", action.edit_last_output },
    { MOD, "^", action.edit_selection_text },
    { MOD, "&", action.edit_pane_text },
    { MOD, "*", action.edit_scrollback_text },
    { MOD, "(", wezterm.action.SwitchWorkspaceRelative(-1) },
    { MOD, ")", wezterm.action.SwitchWorkspaceRelative(1) },
    { LEADER, "1", action.switch_to_workspace({ index = 1 }) },
    { LEADER, "2", action.switch_to_workspace({ index = 2 }) },
    { LEADER, "3", action.switch_to_workspace({ index = 3 }) },
    { LEADER, "4", action.switch_to_workspace({ index = 4 }) },
    { LEADER, "5", action.switch_to_workspace({ index = 5 }) },
    { LEADER, "6", action.switch_to_workspace({ index = 6 }) },
    { LEADER, "7", action.switch_to_workspace({ index = 7 }) },
    { LEADER, "8", action.switch_to_workspace({ index = 8 }) },
    { LEADER, "?", wezterm.action.ShowLauncherArgs({ flags = "FUZZY|KEY_ASSIGNMENTS" }) },
    { LEADER, "d", wezterm.action.ShowLauncherArgs({ flags = "DOMAINS" }) },
    { SUPER, ".", action.rename_workspace },
    { SUPER_SHIFT, ">", action.rename_tab },
    { MOD, "c", wezterm.action.CopyTo("Clipboard") },
    { MOD, "v", wezterm.action.PasteFrom("Clipboard") },
    { LEADER, "v", wezterm.action.ActivateCopyMode },
    { MOD, "F", wezterm.action.QuickSelect },
    { MOD, "E", action.quick_select_open }, -- https://loganlinn.com
    { LEADER, "Space", wezterm.action.ActivateCommandPalette },
    { SUPER_SHIFT, "E", action.browse_current_working_dir },
    { MOD, "Home", wezterm.action.ScrollToTop },
    { MOD, "PageDown", wezterm.action.ScrollToPrompt(1) },
    { MOD, "PageUp", wezterm.action.ScrollToPrompt(0) },
    { MOD, "End", wezterm.action.ScrollToBottom },
    { SUPER, "f", wezterm.action.Search({ CaseSensitiveString = "" }) },
    { SUPER_SHIFT, "-", wezterm.action.DecreaseFontSize },
    { SUPER_SHIFT, "0", wezterm.action.ResetFontSize },
    { SUPER_SHIFT, "=", wezterm.action.IncreaseFontSize },
    { SUPER_SHIFT, "I", wezterm.action.ShowDebugOverlay },
    { SUPER_SHIFT, "D", action.show_hammerspoon_repl },
    { SUPER_SHIFT, "Q", wezterm.action.QuitApplication },
    { SUPER_SHIFT, "R", wezterm.action.ReloadConfiguration },
    { SUPER_SHIFT, ",", action.show_config },
    { SUPER_SHIFT, "?", action.show_keys },
    { SUPER, "UpArrow", wezterm.action.ScrollToPrompt(-1) },
    { SUPER, "DownArrow", wezterm.action.ScrollToPrompt(1) },
    { SUPER, "Home", wezterm.action.ScrollToTop },
    { SUPER, "PageDown", wezterm.action.ScrollByPage(1) },
    { SUPER, "PageUp", wezterm.action.ScrollByPage(-1) },
    { SUPER, "End", wezterm.action.ScrollToBottom },
    { SUPER, "F6", action.debug_window },
    { SUPER, "F7", action.debug_pane },
    { SUPER, "F8", action.debug_globals },
    { SUPER, "F9", action.toggle_debug_key_events },

    { LEADER, "h", wezterm.action.SplitPane({ direction = "Left", size = { Cells = 100 } }) },
    { LEADER, "j", wezterm.action.SplitPane({ direction = "Down", size = { Cells = 20 } }) },
    { LEADER, "k", wezterm.action.SplitPane({ direction = "Up", size = { Cells = 20 } }) },
    { LEADER, "l", wezterm.action.SplitPane({ direction = "Right", size = { Cells = 100 } }) },

    { SUPER, "h", wezterm.action.SplitPane({ direction = "Left", size = { Cells = 100 } }) },
    { SUPER, "j", wezterm.action.SplitPane({ direction = "Down", size = { Cells = 20 } }) },
    { SUPER, "k", wezterm.action.SplitPane({ direction = "Up", size = { Cells = 20 } }) },
    { SUPER, "l", wezterm.action.SplitPane({ direction = "Right", size = { Cells = 100 } }) },

    { MOD, "p", wezterm.action.ActivateKeyTable({ name = "Select" }) },
    Select = {
      { NONE, "e", action.quick_select_open },
      { NONE, "f", wezterm.action.QuickSelect },
      { NONE, "y", wezterm.action.QuickSelectArgs({ patterns = { "\\S+://\\S+" } }) },
      { NONE, "l", wezterm.action.QuickSelectArgs({ patterns = { "^(?!\\s*$).+$" } }) },
      { NONE, "w", wezterm.action.QuickSelectArgs({ patterns = { "\\S+" } }) },
      { NONE, "d", wezterm.action.QuickSelectArgs({ patterns = { "\\d+" } }) },
      { NONE, "h", wezterm.action.QuickSelectArgs({ patterns = { "\\h+" } }) },
      { NONE, "c", wezterm.action.QuickSelectArgs({ patterns = { "[A-Z-_]+" } }) },
      { NONE, "q", wezterm.action.QuickSelectArgs({ patterns = { [[(?<=["'])[^"']+(?=["'])]] } }) },
      -- { -- 1.2.3
      --   NONE,
      --   "v",
      --   wezterm.action.QuickSelectArgs({
      --     patterns = {
      --       [[(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:?:-(?:(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?:[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?]],
      --     },
      --   }),
      -- },
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

    { MOD, "X", wezterm.action.ActivateCopyMode },
    { SUPER, "c", wezterm.action.ActivateCopyMode },
    copy_mode = { -- NOTE: these extend the defaults via `wezterm.gui.default_key_tables()` above
      { NONE, "s", wezterm.action.CopyMode({ SetSelectionMode = "SemanticZone" }) },
      { CTRL, "p", wezterm.action.CopyMode({ MoveBackwardZoneOfType = "Prompt" }) },
      { CTRL, "n", wezterm.action.CopyMode({ MoveForwardZoneOfType = "Prompt" }) },
      { CTRL, "p", wezterm.action.CopyMode({ MoveBackwardZoneOfType = "Prompt" }) },
      { CTRL, "P", wezterm.action.CopyMode({ MoveForwardZoneOfType = "Prompt" }) },
      { CTRL, "i", wezterm.action.CopyMode({ MoveBackwardZoneOfType = "Input" }) },
      { CTRL, "I", wezterm.action.CopyMode({ MoveForwardZoneOfType = "Input" }) },
      { CTRL, "o", wezterm.action.CopyMode({ MoveBackwardZoneOfType = "Output" }) },
      { CTRL, "O", wezterm.action.CopyMode({ MoveForwardZoneOfType = "Output" }) },
    },
  })

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
