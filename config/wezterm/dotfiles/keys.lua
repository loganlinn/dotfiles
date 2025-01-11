local wezterm = require("wezterm")
local A = require("dotfiles.action")
local log = require("dotfiles.util.logger").new("dotfiles.keys")

local NONE = [[NONE]]
local CTRL = [[CTRL]]
local SHIFT = [[SHIFT]]
local SUPER = [[SUPER]]
local LEADER = [[LEADER]]
local MOD = [[CTRL|SHIFT]]

local M = {}

-- ---@param mods string|nil
-- ---@param key string
-- ---@param action KeyAssignment
-- ---@return Key
-- function M.Key(mods, key, action)
--   assert(type(key) == "string")
--   return {
--     key = tostring(key),
--     mods = tostring(mods or NONE),
--     action = action,
--   }
-- end

---@param arg table
---@return Key
function M.tokey(arg)
  if arg[1] then
    assert(arg.mods == nil)
    arg.mods = arg[1]
    arg[1] = nil
  end
  if arg[2] then
    assert(arg.key == nil)
    arg.key = tostring(arg[2])
    arg[2] = nil
  end
  if arg[3] then
    assert(arg.action == nil)
    arg.action = arg[3]
    arg[3] = nil
  end

  -- if arg.mods == nil then
  --   arg.mods = NONE
  -- elseif type(arg.mods) == "table" then
  --   arg.mods = table.concat(arg.mods, "|")
  -- end

  return arg
end

---@param config Config
---@param name? string
---@return Key[]
function M.get_key_table(config, name)
  if name == nil then
    config.keys = config.keys or {}
    return config.keys
  end
  config.key_tables = config.key_tables or {}
  config.key_tables[name] = config.key_tables[name] or {}
  return config.key_tables[name]
end

function M.configure_keys(config, opts)
  for k, v in pairs(opts) do
    if type(k) == "string" then
      local keys = M.get_key_table(config, k)
      for _, vv in pairs(v) do
        table.insert(keys, M.tokey(vv))
      end
    else
      table.insert(config.keys, M.tokey(v))
    end
  end
end

---@param config Config
---@return Config
function M.apply_to_config(config)
  config.disable_default_key_bindings = true
  config.enable_kitty_keyboard = true
  config.enable_csi_u_key_encoding = false
  config.leader = { mods = [[CTRL|SHIFT]], key = "Space", timeout_milliseconds = math.maxinteger }
  config.keys = config.keys or {}
  config.key_tables = config.key_tables or {}

  M.configure_keys(config, {
    { MOD, "H", A.activate_direction("Left") },
    { MOD, "J", A.activate_direction("Down") },
    { MOD, "K", A.activate_direction("Up") },
    { MOD, "L", A.activate_direction("Right") },
    { MOD, "DownArrow", wezterm.action.AdjustPaneSize({ "Down", 15 }) },
    { MOD, "LeftArrow", wezterm.action.AdjustPaneSize({ "Left", 15 }) },
    { MOD, "RightArrow", wezterm.action.AdjustPaneSize({ "Right", 15 }) },
    { MOD, "UpArrow", wezterm.action.AdjustPaneSize({ "Up", 15 }) },
    { MOD, "W", wezterm.action.CloseCurrentPane({ confirm = true }) },
    { SUPER, "w", wezterm.action.CloseCurrentPane({ confirm = false }) },
    { MOD, "Enter", A.split_pane() },
    { MOD, "~", A.toggle_popup_pane },
    { MOD, "R", wezterm.action.RotatePanes("CounterClockwise") },
    { MOD, "S", wezterm.action.PaneSelect({ mode = "SwapWithActive" }) },
    { MOD, "Z", wezterm.action.TogglePaneZoomState },
    { [[LEADER|SHIFT]], "T", A.move_pane_to_new_tab({ activate = true }) },
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
    { MOD, "9", wezterm.action.SwitchWorkspaceRelative(-1) },
    { MOD, "0", wezterm.action.SwitchWorkspaceRelative(1) },
    { LEADER, "Space", wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
    { LEADER, ".", A.RenameWorkspace },
    { LEADER, "p", A.switch_workspace },
    { MOD, "c", wezterm.action.CopyTo("Clipboard") },
    { MOD, "v", wezterm.action.PasteFrom("Clipboard") },
    { LEADER, "v", wezterm.action.ActivateCopyMode },
    { SUPER, "f", wezterm.action.Search({ CaseSensitiveString = "" }) },
    { MOD, "F", wezterm.action.QuickSelect },
    { MOD, "E", A.quick_open }, -- https://loganlinn.com
    { MOD, "o", wezterm.action.ActivateKeyTable({ name = "Open" }) }, -- https://loganlinn.com
    { [[SUPER|SHIFT]], "E", A.browse_current_working_dir },
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
    { SUPER, "F2", A.RenameTab },
    { SUPER, "F5", wezterm.action.ReloadConfiguration },
    { SUPER, "F6", A.debug_window },
    { SUPER, "F7", A.debug_pane },
    { SUPER, "F8", A.toggle_debug_key_events },
    { MOD, [[|]], wezterm.action.ActivateKeyTable({ name = "Split" }) },
    { LEADER, "i", wezterm.action.ActivateKeyTable({ name = "Insert" }) },

    { LEADER, "r", require("dotfiles.action.yarn-run").input_selector },

    Insert = {
      { NONE, "u", wezterm.action.CharSelect },
      { NONE, "p", wezterm.action.PasteFrom("Clipboard") },
      M.tokey({ SHIFT, "P", wezterm.action.PasteFrom("PrimarySelection") }),
    },

    Split = {
      { NONE, "h", wezterm.action.SplitPane({ top_level = true, direction = "Left" }) },
      { NONE, "j", wezterm.action.SplitPane({ top_level = true, direction = "Down" }) },
      { NONE, "k", wezterm.action.SplitPane({ top_level = true, direction = "Up" }) },
      { NONE, "l", wezterm.action.SplitPane({ top_level = true, direction = "Right" }) },
      { SHIFT, "H", wezterm.action.SplitPane({ direction = "Up" }) },
      { SHIFT, "J", wezterm.action.SplitPane({ direction = "Right" }) },
      { SHIFT, "K", wezterm.action.SplitPane({ direction = "Left" }) },
      { SHIFT, "L", wezterm.action.SplitPane({ direction = "Down" }) },
    },
  })

  -- Mouse bindings
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

  return config
end

return M
