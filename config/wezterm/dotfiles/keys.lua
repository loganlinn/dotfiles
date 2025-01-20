local wezterm = require("wezterm")
local action = require("dotfiles.action")
local NONE = [[NONE]]
local SHIFT = [[SHIFT]]
local SUPER = [[SUPER]]
local LEADER = [[LEADER]]
local MOD = [[CTRL|SHIFT]]

local M = {}

---@alias KeySpec Key|[string, string, KeyAssignment]

---@param config Config
---@return Config
function M.apply_to_config(config)
  config.disable_default_key_bindings = true
  config.enable_kitty_keyboard = true
  config.enable_csi_u_key_encoding = false
  config.leader = { mods = [[CTRL|SHIFT]], key = "Space", timeout_milliseconds = math.maxinteger }
  config.keys = config.keys or {}
  config.key_tables = config.key_tables or {}

  M.with_keys(config, {
    { MOD, "H", action.activate_direction("Left") },
    { MOD, "J", action.activate_direction("Down") },
    { MOD, "K", action.activate_direction("Up") },
    { MOD, "L", action.activate_direction("Right") },
    { MOD, "DownArrow", wezterm.action.AdjustPaneSize({ "Down", 15 }) },
    { MOD, "LeftArrow", wezterm.action.AdjustPaneSize({ "Left", 15 }) },
    { MOD, "RightArrow", wezterm.action.AdjustPaneSize({ "Right", 15 }) },
    { MOD, "UpArrow", wezterm.action.AdjustPaneSize({ "Up", 15 }) },
    { MOD, "W", wezterm.action.CloseCurrentPane({ confirm = true }) },
    { SUPER, "w", wezterm.action.CloseCurrentPane({ confirm = false }) },
    { SUPER, "q", action.quit_input_selector },
    { MOD, "Enter", action.split_pane() },
    { MOD, "~", action.toggle_popup_pane },
    { MOD, "R", wezterm.action.RotatePanes("CounterClockwise") },
    { MOD, "S", wezterm.action.PaneSelect({ mode = "SwapWithActive" }) },
    { MOD, "Z", wezterm.action.TogglePaneZoomState },
    { [[LEADER|SHIFT]], "T", action.move_pane_to_new_tab({ activate = true }) },
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
    {
      MOD,
      "*",
      action.just({ args = { "--justfile", wezterm.home_dir .. "/.dotfiles/justfile", "switch" } }),
    },
    { MOD, "9", wezterm.action.SwitchWorkspaceRelative(-1) },
    { MOD, "0", wezterm.action.SwitchWorkspaceRelative(1) },
    { LEADER, "Space", wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES|DOMAINS" }) },
    { LEADER, ":", wezterm.action.ShowLauncherArgs({ flags = "FUZZY|LAUNCH_MENU_ITEMS" }) },
    { LEADER, "?", wezterm.action.ShowLauncherArgs({ flags = "FUZZY|KEY_ASSIGNMENTS" }) },
    { LEADER, ".", action.rename_workspace },
    { LEADER, ",", action.rename_tab },
    { LEADER, "p", action.switch_workspace },
    { MOD, "c", wezterm.action.CopyTo("Clipboard") },
    { MOD, "v", wezterm.action.PasteFrom("Clipboard") },
    { LEADER, "v", wezterm.action.ActivateCopyMode },
    { SUPER, "f", wezterm.action.Search({ CaseSensitiveString = "" }) },
    { MOD, "F", wezterm.action.QuickSelect },
    { MOD, "E", action.quick_open }, -- https://loganlinn.com
    { MOD, "o", wezterm.action.ActivateKeyTable({ name = "Open" }) }, -- https://loganlinn.com
    { [[SUPER|SHIFT]], "E", action.browse_current_working_dir },
    { MOD, "Home", wezterm.action.ScrollToTop },
    { MOD, "PageDown", wezterm.action.ScrollToPrompt(1) },
    { MOD, "PageUp", wezterm.action.ScrollToPrompt(0) },
    { MOD, "End", wezterm.action.ScrollToBottom },
    { SUPER, "0", wezterm.action.ResetFontSize },
    { SUPER, "-", wezterm.action.DecreaseFontSize },
    { SUPER, "=", wezterm.action.IncreaseFontSize },
    { SUPER, "DownArrow", wezterm.action.AdjustPaneSize({ "Down", 15 }) },
    { SUPER, "UpArrow", wezterm.action.AdjustPaneSize({ "Up", 15 }) },
    { SUPER, "Home", wezterm.action.ScrollToTop },
    { SUPER, "PageDown", wezterm.action.ScrollByPage(1) },
    { SUPER, "PageUp", wezterm.action.ScrollByPage(-1) },
    { SUPER, "End", wezterm.action.ScrollToBottom },
    { SUPER, "UpArrow", wezterm.action.ScrollToPrompt(-1) },
    { SUPER, "DownArrow", wezterm.action.ScrollToPrompt(1) },
    { LEADER, "q", wezterm.action.QuitApplication },
    { MOD, "p", wezterm.action.ActivateCommandPalette },
    { SUPER, "F1", wezterm.action.ShowDebugOverlay },
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
    { SUPER, "F5", wezterm.action.ReloadConfiguration },
    { SUPER, "F6", action.debug_window },
    { SUPER, "F7", action.debug_pane },
    { SUPER, "F9", action.show_config },
    { SUPER, "F8", action.toggle_debug_key_events },
    { SUPER, "F10" },

    { LEADER, "h", wezterm.action.SplitPane({ direction = "Left", size = { Cells = 100 } }) },
    { LEADER, "j", wezterm.action.SplitPane({ direction = "Down", size = { Cells = 20 } }) },
    { LEADER, "k", wezterm.action.SplitPane({ direction = "Up", size = { Cells = 20 } }) },
    { LEADER, "l", wezterm.action.SplitPane({ direction = "Right", size = { Cells = 100 } }) },

    { LEADER, "r", require("dotfiles.action.yarn-run").input_selector },

    Insert = {
      { NONE, "u", wezterm.action.CharSelect },
      { NONE, "p", wezterm.action.PasteFrom("Clipboard") },
      M.key_assignment({ SHIFT, "P", wezterm.action.PasteFrom("PrimarySelection") }),
    },
    { LEADER, "i", wezterm.action.ActivateKeyTable({ name = "Insert" }) },

    Split = {
      { NONE, "h", wezterm.action.SplitPane({ top_level = true, direction = "Left" }) },
      { NONE, "j", wezterm.action.SplitPane({ top_level = true, direction = "Down" }) },
      { NONE, "k", wezterm.action.SplitPane({ top_level = true, direction = "Up" }) },
      { NONE, "l", wezterm.action.SplitPane({ top_level = true, direction = "Right" }) },
    },
    { MOD, [[|]], wezterm.action.ActivateKeyTable({ name = "Split" }) },
  })

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
function M.with_keys(config, keys_spec, key_table)
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
      M.with_keys(config, v, k)
    end
  end
  return config
end

return M
