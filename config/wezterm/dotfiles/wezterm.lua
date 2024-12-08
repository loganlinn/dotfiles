local wezterm = require("wezterm")
local start_time = wezterm.time.now()
local act = require("dotfiles.action")
local util = require("dotfiles.util")

local function victor_mono_font(font)
  font = font or {}
  font.family = "Victor Mono"
  font.harfbuzz_features = font.harfbuzz_features
    or {
      "ss02", -- Slashed zero, variant 1
      "ss07", -- Straighter 6 and 9
    }
  return wezterm.font(font)
end

local config = wezterm.config_builder()

-- config.debug_key_events = true
config:set_strict_mode(true)
config.automatically_reload_config = true
config.font = victor_mono_font({ style = "Normal" })
config.font_size = 14
config.cell_width = 1
config.line_height = 1.1
config.font_rules = {
  { italic = true, font = victor_mono_font({ style = "Oblique" }) },
}
-- config.default_cursor_style = "BlinkingBar"
-- config.cursor_blink_rate = 666
-- config.cursor_thickness = 2
-- config.cursor_blink_ease_in = "Constant"
-- config.cursor_blink_ease_out = "Constant"
-- config.animation_fps = 1
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "0.5cell",
  bottom = "0.5cell",
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
config.hyperlink_rules = {
  {
    format = "$1",
    highlight = 1,
    regex = "\\((\\w+://\\S+)\\)",
  },
  {
    format = "$1",
    highlight = 1,
    regex = "\\[(\\w+://\\S+)\\]",
  },
  {
    format = "$1",
    highlight = 1,
    regex = "<(\\w+://\\S+)>",
  },
  {
    format = "$0",
    highlight = 0,
    regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
  },
  {
    format = "https://linear.app/gamma-app/issue/$1",
    highlight = 1,
    regex = "\\b([gG]-\\d+)\\b",
  },
  {
    regex = [[error: could not format file ([^:]+):.+starting from line (\d+).+character (\d+).+ending on line (\d+).+character (\d+)]],
    format = [[file://$1#$2.$3:$4.$5]],
    highlight = 1,
  },
}
config.quick_select_patterns = {
  "[\\h]{7,40}", -- SHA1 hashes, usually used for Git.
  "[\\h]{7,64}", -- SHA256 hashes, used often for getting hashes for Guix packaging.
  "sha256-.{44,128}", -- SHA256 hashes in Base64, used often in getting hashes for Nix packaging.
  "sha512-.{44,128}", -- SHA512 hashes in Base64, used often in getting hashes for Nix packaging.
  "'nix [^']+.drv'", -- single quoted strings
  [[(?:[-._~/a-zA-Z0-9])*[/ ](?:[-._~/a-zA-Z0-9]+)]], -- unix paths
  "(?<= | | | | | | | | | | | | | |󰢬 | | | |└──|├──)\\s?(\\S+)",
}
for _, pattern in ipairs(wezterm.default_hyperlink_rules()) do
  table.insert(config.quick_select_patterns, pattern.regex)
end
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = true
config.leader = { mods = "CTRL|SHIFT", key = "Space" }
config.leader.timeout_milliseconds = math.maxinteger
--[[ Hyper, Super, Meta, Cancel, Backspace, Tab, Clear, Enter, Shift, Escape, LeftShift, RightShift, Control, LeftControl, RightControl, Alt, LeftAlt, RightAlt, Menu, LeftMenu, RightMenu, Pause, CapsLock, VoidSymbol, PageUp, PageDown, End, Home, LeftArrow, RightArrow, UpArrow, DownArrow, Select, Print, Execute, PrintScreen, Insert, Delete, Help, LeftWindows, RightWindows, Applications, Sleep, Numpad0, Numpad1, Numpad2, Numpad3, Numpad4, Numpad5, Numpad6, Numpad7, Numpad8, Numpad9, Multiply, Add, Separator, Subtract, Decimal, Divide, NumLock, ScrollLock, BrowserBack, BrowserForward, BrowserRefresh, BrowserStop, BrowserSearch, BrowserFavorites, BrowserHome, VolumeMute, VolumeDown, VolumeUp, MediaNextTrack, MediaPrevTrack, MediaStop, MediaPlayPause, ApplicationLeftArrow, ApplicationRightArrow, ApplicationUpArrow, ApplicationDownArrow, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24. ]]
local function add_keys(...)
  config.keys = config.keys or {}
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    if arg then
      local mods, key, action = arg.mods or arg[1], arg.key or arg[2], arg.action or arg[3]
      if key and action then
        -- wezterm.log_info("adding key", key, mods, action)
        table.insert(config.keys, { key = key, mods = mods, action = action })
      end
    end
  end
end

add_keys(
  -- Tab
  { "CTRL", "Tab", act.ActivateTabRelative(1) },
  { "CTRL|SHIFT", "Tab", act.ActivateTabRelative(-1) },
  { "CTRL|SHIFT", "{", act.ActivateTabRelative(-1) },
  { "CTRL|SHIFT", "}", act.ActivateTabRelative(1) },
  { "CTRL|SHIFT", ",", act.MoveTabRelative(-1) },
  { "CTRL|SHIFT", ".", act.MoveTabRelative(1) },
  { "CTRL|SHIFT", "Enter", act.SplitPaneAuto() },
  { "CTRL|SHIFT", "Z", act.TogglePaneZoomState },
  { "CTRL|SHIFT", "`", act.TogglePaneZoomState },
  -- Pane
  { "CTRL|SHIFT", "b", act.RotatePanes("CounterClockwise") },
  { "CTRL|SHIFT", "h", act.ActivatePaneDirection("Left") },
  { "CTRL|SHIFT", "j", act.ActivatePaneDirection("Down") },
  { "CTRL|SHIFT", "k", act.ActivatePaneDirection("Up") },
  { "CTRL|SHIFT", "l", act.ActivatePaneDirection("Right") },
  { "CTRL|SHIFT", "T", act.SpawnTab("CurrentPaneDomain") },
  { "CTRL|SHIFT", "LeftArrow", act.AdjustPaneSize({ "Left", 5 }) },
  { "CTRL|SHIFT", "DownArrow", act.AdjustPaneSize({ "Down", 5 }) },
  { "CTRL|SHIFT", "UpArrow", act.AdjustPaneSize({ "Up", 5 }) },
  { "CTRL|SHIFT", "RightArrow", act.AdjustPaneSize({ "Right", 5 }) },
  { "CTRL|SHIFT", ">", act.AdjustPaneSize({ "Right", 25 }) },
  { "CTRL|SHIFT", "<", act.AdjustPaneSize({ "Left", 25 }) },
  { "CTRL|SHIFT", "t", act.SpawnTab("CurrentPaneDomain") },
  { "CTRL|SHIFT", "w", act.CloseCurrentPane({ confirm = true }) },
  { "SUPER", "w", act.CloseCurrentPane({ confirm = true }) },
  -- Window
  { "SUPER|SHIFT", "n", act.SpawnWindow },
  -- Scroll
  { "SUPER", "Home", act.ScrollToTop },
  { "SUPER", "PageDown", act.ScrollByPage(1) },
  { "SUPER", "PageUp", act.ScrollByPage(-1) },
  { "SUPER", "End", act.ScrollToBottom },
  { "SUPER", "UpArrow", act.ScrollToPrompt(-1) },
  { "SUPER", "DownArrow", act.ScrollToPrompt(1) },
  -- Clipboard
  { "CTRL|SHIFT", "c", act.CopyTo("Clipboard") },
  { "CTRL|SHIFT", "v", act.PasteFrom("Clipboard") },
  { "CTRL|SHIFT", "F", act.QuickSelect },
  { "CTRL|SHIFT", "e", act.QuickSelectUrl }, -- https://loganlinn.com
  -- Workspace
  { "SUPER", "n", act.SwitchToNamedWorkspace },
  -- Leader
  { "LEADER", "|", act.SplitPane({ direction = "Right", top_level = true }) },
  { "LEADER|CTRL", "|", act.SplitPane({ direction = "Left", top_level = true }) },
  { "LEADER", ".", act.RenameWorkspace },
  { "LEADER", "-", act.SplitPane({ direction = "Down" }) },
  { "LEADER|CTRL", "-", act.SplitPane({ direction = "Up" }) },
  { "LEADER", "\\", act.SplitPane({ direction = "Right" }) },
  { "LEADER|CTRL", "\\", act.SplitPane({ direction = "Left" }) },
  { "LEADER", "_", act.SplitPane({ direction = "Down", top_level = true }) },
  { "LEADER|CTRL", "_", act.SplitPane({ direction = "Up", top_level = true }) },
  { "LEADER", "T", act.MovePaneToNewTab({ activate = true }) },
  { "LEADER|SHIFT", "W", act.PaneSelect({ mode = "MoveToNewWindow" }) },
  { "LEADER|SHIFT", "M", act.PaneSelect({ mode = "SwapWithActive" }) },
  { "LEADER|SHIFT", "R", act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },
  { "LEADER|SHIFT", "Tab", act.SwitchWorkspaceRelative(-1) },
  { "LEADER", "Tab", act.SwitchWorkspaceRelative(1) },
  { "LEADER", "Space", act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  { "LEADER", "h", act.ActivatePaneDirection("Left") },
  { "LEADER", "j", act.ActivatePaneDirection("Down") },
  { "LEADER", "k", act.ActivatePaneDirection("Up") },
  { "LEADER", "l", act.ActivatePaneDirection("Right") },
  { "LEADER", "v", act.ActivateCopyMode },
  -- { "LEADER", "Tab", act.ActivateKeyTable({ name = "workspace" }) },
  { "LEADER", "i", act.ActivateKeyTable({ name = "insert" }) },
  { "LEADER", "t", act.ActivateKeyTable({ name = "toggle" }) },
  { "LEADER", "w", act.ActivateKeyTable({ name = "window" }) },
  { "LEADER", "g", act.ActivateKeyTable({ name = "git" }) },
  -- Other
  { "SUPER", "F1", act.ShowDebugOverlay },
  { "SUPER", "F2", act.RenameTab },
  { "SUPER", "F5", act.ReloadConfiguration },
  { "SUPER", "F6", act.DumpWindow },
  { "SUPER", "F7", act.ToggleDebugKeyEvents },
  { "SUPER", "F9", act.ShowTabNavigator },
  { "SUPER", "F10", act.InputSelectorDemo },
  { "SUPER", "f", act.Search({ CaseSensitiveString = "" }) },
  { "SUPER", "0", wezterm.action.ResetFontSize },
  { "SUPER", "-", wezterm.action.DecreaseFontSize },
  { "SUPER", "=", wezterm.action.IncreaseFontSize },
  { "CTRL|SHIFT", "p", act.ActivateCommandPalette },
  { "SUPER", ";", act.ShowLauncher }
)
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "SUPER",
    action = act.ActivateTab(i - 1),
  })
end

config.keys = config.keys or {}
config.key_tables = config.key_tables or {}

config.key_tables["insert"] = {
  { key = "u", action = act.CharSelect },
  { key = "p", action = act.PasteFrom("Clipboard") },
  { key = "P", action = act.PasteFrom("PrimarySelection") },
}
--
-- config.key_tables["git"] = {
--   { key = "a", mods = "CTRL", action = act.SpawnCommandInNewWindow({ args = { "gh", "pr", "checks", "--watch" } }) },
-- }

-- require("dotfiles.util.keymap")
--   :create()
--   :bind({
--     prefix = { "toggle", key = "t", mods = "LEADER" },
--     { key = "z", action = act.TogglePaneZoomState },
--     { key = "s", action = act.ToggleAlwaysOnTop },
--     { key = "s", mods = "SHIFT", action = act.ToggleAlwaysOnBottom },
--     { key = "f", action = act.ToggleFullScreen },
--   })
--   :bind({
--     prefix = { "window", key = "w", mods = "LEADER" },
--     { key = "d", action = act.CloseCurrentTab({ confirm = true }) },
--     { key = "n", action = act.SpawnWindow },
--     { key = "s", action = act.PaneSelect({ mode = "SwapWithActive" }) },
--   })
-- :bind({ prefix = {"help", key = "h", mods = "LEADER" }, })
-- :apply_to_config(config)

-- define_key_table(
--   "window",
--   "LEADER",
--   "w",
-- )
--
-- define_key_table(
--   "insert",
--   "LEADER",
--   "i",
--   with_cancel_keys({
--     { key = "u", action = act.CharSelect },
--     { key = "p", action = act.PasteFrom("Clipboard") },
--     { key = "P", action = act.PasteFrom("PrimarySelection") },
--   })
-- )

-- Debug events
for _, event in ipairs({
  "mux-startup",
  "gui-startup",
  "gui-attached",
  "open-uri",
}) do
  wezterm.on(event, function(...)
    wezterm.log_info("EVENT", event, "args=", { ... })
  end)
end

require("dotfiles.tabline").apply_to_config(config)
require("dotfiles.balance").apply_to_config(config)

wezterm.on("open-uri", function(window, pane, uri)
  local url = wezterm.url.parse(uri)
  wezterm.log_info("parsed url", url)

  if url.scheme == "file" then
    -- window:perform_action(
    --   act.SpawnCommandInNewTab({
    --     cwd = util.dirname(url.file_path),
    --     args = { "zsh", "-c", 'yazi "$1"', "zsh", url.file_path },
    --     -- args = { "yazi", url.file_path },
    --   }),
    --   pane
    -- )

    wezterm.open_with(uri, "WezTerm")
    return false
  else
    wezterm.open_with(uri)
  end
end)

wezterm.log_info("FINISH", "wezterm.lua", "elapsed: " .. util.time_diff_ms(wezterm.time.now(), start_time) .. " ms")

return config
