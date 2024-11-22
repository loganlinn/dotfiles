local wezterm = require("wezterm") -- https://wezfurlong.org/wezterm/config/lua/config
local act = require("dotfiles.util.action")
local log = require("dotfiles.util.log")
local balance = require("dotfiles.balance")
local tabline = require("dotfiles.tabline")
local utils = require("dotfiles.utils")
local is, safe = utils.is, utils.safe

local function victor_mono(fontattr)
  fontattr = fontattr or {}
  fontattr.family = "Victor Mono"
  fontattr.harfbuzz_features = fontattr.harfbuzz_features
    or {
      -- "ss01", -- Single-storey a
      "ss02", -- Slashed zero, variant 1
      -- "ss03", -- Slashed zero, variant 2
      -- "ss04", -- Slashed zero, variant 3
      -- "ss05", -- Slashed zero, variant 4
      -- "ss06", -- Slashed seven
      "ss07", -- Straighter 6 and 9
      -- "ss08", -- More fishlike turbofish (previous default ::< ligature)
    }
  return wezterm.font(fontattr)
end

local config = wezterm.config_builder()
-- config.debug_key_events = true
config:set_strict_mode(true)
config.automatically_reload_config = true
config.font = victor_mono({ style = "Normal" })
config.font_size = 14
config.cell_width = 1
config.line_height = 1.1
config.font_rules = {
  { italic = true, font = victor_mono({ style = "Oblique" }) },
}
config.default_cursor_style = "BlinkingBar"
config.window_frame = { font = config.font }
config.window_padding = {
  right = "1cell",
  left = "1cell",
}
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.7,
}
config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = "BrightAndBold"
config.enable_scroll_bar = true
config.initial_cols = 140
config.initial_rows = 70
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false -- do not use native ui
config.window_decorations = "RESIZE"
config.command_palette_font_size = config.font_size
config.command_palette_font_size = config.font_size
config.command_palette_rows = 10
config.exit_behavior = "CloseOnCleanExit" -- Use 'Hold' to not close
config.quit_when_all_windows_are_closed = true
config.switch_to_last_active_tab_when_closing_tab = true
config.check_for_updates = false
config.hide_tab_bar_if_only_one_tab = false
config.native_macos_fullscreen_mode = false
config.quick_select_patterns = {
  "[0-9a-f]{7,40}", -- SHA1 hashes, usually used for Git.
  "[0-9a-f]{7,64}", -- SHA256 hashes, used often for getting hashes for Guix packaging.
  "sha256-.{44,128}", -- SHA256 hashes in Base64, used often in getting hashes for Nix packaging.
  "sha512-.{44,128}", -- SHA512 hashes in Base64, used often in getting hashes for Nix packaging.
  "'nix [^']+.drv'", -- single quoted strings
}
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = true

config.leader = {
  mods = utils.match_platform({
    linux = "META",
    darwin = "CMD",
    windows = "ALT",
  }),
  key = "Space",
  timeout_milliseconds = math.maxinteger,
}

local function define_key(mods, key, action)
  if config.keys == nil then
    config.keys = {}
  end
  local key = { key = key, mods = mods or "NONE", action = action or act.Nop }
  table.insert(config.keys, key)
  return key
end

local function define_key_table(name, mods, key, key_table)
  if config.key_tables == nil then
    config.key_tables = {}
  end
  define_key(mods, key, act.ActivateKeyTable({ name = name }))
  config.key_tables[name] = key_table
  return key_table
end

local function with_cancel_keys(key_table)
  table.insert(key_table, { key = "Escape", action = act.ClearKeyTableStack })
  table.insert(key_table, { key = "g", mods = "CTRL", action = act.ClearKeyTableStack })
  table.insert(key_table, { key = "c", mods = "CTRL", action = act.ClearKeyTableStack })
  return key_table
end

config.keys = {
  -- Tab
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "{", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "}", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "<", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
  { key = ">", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
  { key = "Enter", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  -- Pane
  { key = "-", mods = "LEADER", action = act.SplitPane({ direction = "Down" }) },
  { key = "-", mods = "LEADER|CTRL", action = act.SplitPane({ direction = "Up" }) },
  { key = "\\", mods = "LEADER", action = act.SplitPane({ direction = "Right" }) },
  { key = "\\", mods = "LEADER|CTRL", action = act.SplitPane({ direction = "Left" }) },
  { key = "_", mods = "LEADER", action = act.SplitPane({ direction = "Down", top_level = true }) },
  { key = "_", mods = "LEADER|CTRL", action = act.SplitPane({ direction = "Up", top_level = true }) },
  { key = "1", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
  { key = "2", mods = "CTRL|SHIFT", action = act.ToggleSidePane },
  { key = "b", mods = "CTRL|SHIFT", action = act.RotatePanes("CounterClockwise") },
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "h", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "j", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "k", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "l", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "w", mods = "SUPER", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "|", mods = "LEADER", action = act.SplitPane({ direction = "Right", top_level = true }) },
  { key = "|", mods = "LEADER|CTRL", action = act.SplitPane({ direction = "Left", top_level = true }) },
  -- Window
  { key = "n", mods = "SUPER|SHIFT", action = act.SpawnWindow },

  -- Scroll
  { key = "Home", mods = "CTRL|SHIFT", action = act.ScrollToTop },
  { key = "PageDown", mods = "CTRL|SHIFT", action = act.ScrollByPage(1) },
  { key = "PageUp", mods = "CTRL|SHIFT", action = act.ScrollByPage(-1) },
  { key = "End", mods = "CTRL|SHIFT", action = act.ScrollToBottom },

  -- Clipboard
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "f", mods = "CTRL|SHIFT", action = act.QuickSelect },
  {
    key = "e",
    mods = "CTRL|SHIFT",
    action = wezterm.action({
      QuickSelectArgs = {
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
      },
    }),
  },
  -- Workspace
  { key = "n", mods = "SUPER", action = act.SwitchToNamedWorkspace },
  { key = "[", mods = "SUPER|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
  { key = "]", mods = "SUPER|SHIFT", action = act.SwitchWorkspaceRelative(1) },
  { key = "Tab", mods = "LEADER", action = act.ActivateKeyTable({ name = "workspace" }) },
  { key = ".", mods = "LEADER", action = act.RenameWorkspace },
  -- Other
  { key = "F1", mods = "SUPER", action = act.ShowDebugOverlay },
  { key = "F2", mods = "SUPER", action = act.RenameTab },
  { key = "F5", mods = "SUPER", action = act.ReloadConfiguration },
  { key = "F9", mods = "SUPER", action = wezterm.action.ShowTabNavigator },
  { key = "f", mods = "SUPER", action = act.Search({ CaseSensitiveString = "" }) },
  { key = "-", mods = "SUPER", action = wezterm.action.DecreaseFontSize },
  { key = "=", mods = "SUPER", action = wezterm.action.IncreaseFontSize },
  { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
  { key = ";", mods = "SUPER", action = act.ShowLauncher },
  { key = "Space", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "i", mods = "LEADER", action = act.ActivateKeyTable({ name = "insert" }) },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "t", mods = "LEADER", action = act.ActivateKeyTable({ name = "toggle" }) },
  { key = "v", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "w", mods = "LEADER", action = act.ActivateKeyTable({ name = "window" }) },
}
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "SUPER",
    action = act.ActivateTab(i - 1),
  })
end

config.key_tables = {}

define_key_table(
  "toggle",
  "LEADER",
  "t",
  with_cancel_keys({
    { key = "z", action = act.TogglePaneZoomState },
    { key = "s", action = act.ToggleAlwaysOnTop },
    { key = "s", mods = "SHIFT", action = act.ToggleAlwaysOnBottom },
    { key = "f", action = act.ToggleFullScreen },
  })
)

define_key_table(
  "window",
  "LEADER",
  "w",
  with_cancel_keys({
    { key = "d", action = act.CloseCurrentTab({ confirm = true }) },
    { key = "n", action = act.SpawnWindow },
    { key = "s", action = act.PaneSelect({ mode = "SwapWithActive" }) },
  })
)

define_key_table(
  "insert",
  "LEADER",
  "i",
  with_cancel_keys({
    { key = "u", action = act.CharSelect },
    { key = "p", action = act.PasteFrom("Clipboard") },
    { key = "P", action = act.PasteFrom("PrimarySelection") },
  })
)

wezterm.on("window-resized", function(window, pane)
  log.info("on: window-resized")
end)

wezterm.on("window-config-reloaded", function(window)
  wezterm.GLOBAL.config_reloaded_count = (wezterm.GLOBAL.config_reloaded_count or 0) + 1
  log.info("on: window-config-reloaded", wezterm.GLOBAL.config_reloaded_count)
end)

tabline.apply_to_config(config)
balance.apply_to_config(config)

return config
