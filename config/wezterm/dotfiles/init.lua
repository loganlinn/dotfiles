local wezterm = require 'wezterm' -- https://wezfurlong.org/wezterm/config/lua/config
local act = wezterm.action
-- local color = wezterm.color
-- local gui = wezterm.gui
-- local mux = wezterm.mux
-- local procinfo = wezterm.procinfo
-- local serde = wezterm.serde
-- local time = wezterm.time
-- local url = wezterm.url

local utils = require('dotfiles.utils')

local config = wezterm.config_builder()

config:set_strict_mode(true)

local function victor_mono(fontattr)
  fontattr = fontattr or {}
  fontattr.family = "Victor Mono"
  fontattr.harfbuzz_features = fontattr.harfbuzz_features or {
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

config.font = victor_mono { style = "Normal" }
config.font_size = 14
config.cell_width = 1
config.line_height = 1.1
config.font_rules = {
  { italic = true, font = victor_mono { style = "Oblique" } },
}

config.window_frame = { font = config.font }
config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = "BrightAndBold";
config.enable_scroll_bar = true
config.initial_cols = 140
config.initial_rows = 70
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false -- do not use native ui
config.window_decorations = "RESIZE"
config.inactive_pane_hsb = {
  saturation = 0.90,
  brightness = 0.75,
}

-- -- The filled in variant of the < symbol
-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
--
-- -- The filled in variant of the > symbol
-- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
--
-- -- This function returns the suggested title for a tab.
-- -- It prefers the title that was set via `tab:set_title()`
-- -- or `wezterm cli set-tab-title`, but falls back to the
-- -- title of the active pane in that tab.
-- local function tab_title(tab_info)
--   local title = tab_info.tab_title
--   -- if the tab title is explicitly set, take that
--   if title and #title > 0 then
--     return title
--   end
--   -- Otherwise, use the title from the active pane
--   -- in that tab
--   return tab_info.active_pane.title
-- end
--
-- wezterm.on(
--   'format-tab-title',
--   function(tab, tabs, panes, config, hover, max_width)
--     local edge_background = '#0b0022'
--     local background = '#1b1032'
--     local foreground = '#808080'
--
--     if tab.is_active then
--       background = '#2b2042'
--       foreground = '#c0c0c0'
--     elseif hover then
--       background = '#3b3052'
--       foreground = '#909090'
--     end
--
--     local edge_foreground = background
--
--     local title = tab_title(tab)
--
--     -- ensure that the titles fit in the available space,
--     -- and that we have room for the edges.
--     title = wezterm.truncate_right(title, max_width - 2)
--
--     return {
--       { Background = { Color = edge_background } },
--       { Foreground = { Color = edge_foreground } },
--       { Text = SOLID_LEFT_ARROW },
--       { Background = { Color = background } },
--       { Foreground = { Color = foreground } },
--       { Text = title },
--       { Background = { Color = edge_background } },
--       { Foreground = { Color = edge_foreground } },
--       { Text = SOLID_RIGHT_ARROW },
--     }
--   end
-- )

config.command_palette_font_size = config.font_size
config.command_palette_font_size = config.font_size
config.command_palette_rows = 10
-- config.command_palette_bg_color = TODO
-- config.command_palette_fg_color = TODO

config.exit_behavior = "CloseOnCleanExit" -- Use 'Hold' to not close
config.quit_when_all_windows_are_closed = true
config.switch_to_last_active_tab_when_closing_tab = true
config.check_for_updates = false
config.hide_tab_bar_if_only_one_tab = true
config.native_macos_fullscreen_mode = false
-- config.selection_word_boundary = '{}[]()"\'`.,;:'

local function insert_keys(...)
  if config.keys == nil then config.keys = {} end
  local p = {}
  for k, v in pairs({ ... }) do
    if type(k) == "number" then
      local key = {}
      for pk, pv in pairs(p) do key[pk] = pv end
      for vk, vv in pairs(v) do key[vk] = vv end
      table.insert(config.keys, key)
    else
      for vk, vv in pairs(v) do p[vk] = vv end
    end
  end
end

config.disable_default_key_bindings = true
-- config.enable_kitty_keyboard = true --  honor kitty keyboard protocol escape sequences that modify the keyboard encoding
-- config.use_ime = false
-- config.use_dead_keys = false
-- config.debug_key_events = true
-- config.leader = {
--   mod = "CTRL|SHIFT",
--   key = "Space",
--   timeout_milliseconds = 1000,
-- }
config.keys = {
  -- Tab Focus
  { key = "Tab",   mods = "CTRL",             action = act.ActivateTabRelative(1), },
  { key = "Tab",   mods = "CTRL|SHIFT",       action = act.ActivateTabRelative(-1), },

  -- Tab Position
  { key = "<",     mods = "CTRL|SHIFT",       action = act.MoveTabRelative(-1) },
  { key = ">",     mods = "CTRL|SHIFT",       action = act.MoveTabRelative(1) },

  -- Pane Lifecycle
  { key = "Enter", mods = "CTRL|SHIFT",       action = act.SplitHorizontal { domain = "CurrentPaneDomain" }, },
  { key = "Enter", mods = "CTRL|SHIFT|SUPER", action = act.SplitVertical { domain = "CurrentPaneDomain" }, },
  { key = "t",     mods = "CTRL|SHIFT",       action = act.SpawnTab 'CurrentPaneDomain' },
  { key = "w",     mods = "CTRL|SHIFT",       action = act.CloseCurrentPane { confirm = true }, },
  { key = "w",     mods = "SUPER",            action = act.CloseCurrentPane { confirm = true }, },

  -- Window Lifecycle
  { key = "n",     mods = "SUPER",            action = act.SpawnWindow, },
  {
    key = 'N',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },

  -- Workspace
  { key = "{",         mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
  { key = "}",         mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(1) },
  { key = "Backslash", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },

  -- Tabs
  {
    key = 'e',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'Tab name',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Pane Focus
  { key = "h",         mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Left") },
  { key = "j",         mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Down") },
  { key = "k",         mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Up") },
  { key = "l",         mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Right") },

  -- Pane Size
  { key = 'h',         mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'j',         mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'k',         mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'l',         mods = 'CTRL|SHIFT|ALT', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Pane Misc
  { key = "b",         mods = "CTRL|SHIFT",     action = act.RotatePanes 'CounterClockwise' },
  { key = 'z',         mods = 'CTRL|SHIFT',     action = act.TogglePaneZoomState, },

  -- Scroll
  { key = "Home",      mods = "CTRL|SHIFT",     action = act.ScrollToTop, },
  { key = "PageDown",  mods = "CTRL|SHIFT",     action = act.ScrollByPage(1), },
  { key = "PageUp",    mods = "CTRL|SHIFT",     action = act.ScrollByPage(-1), },
  { key = "End",       mods = "CTRL|SHIFT",     action = act.ScrollToBottom, },

  -- System
  { key = "c",         mods = "CTRL|SHIFT",     action = act.CopyTo "Clipboard", },
  { key = "v",         mods = "CTRL|SHIFT",     action = act.PasteFrom "Clipboard", },

  -- Misc
  { key = 'F1',        mods = "SUPER",          action = act.ShowDebugOverlay, },
  { key = "f",         mods = "SUPER",          action = act.Search { CaseSensitiveString = "" }, },
  { key = "Semicolon", mods = "CTRL|SHIFT",     action = act.ShowLauncher, },
  { key = "'",         mods = "CTRL|SHIFT",     action = act.QuickSelect, },
  { key = "p",         mods = "CTRL|SHIFT",     action = act.ActivateCommandPalette, },
  { key = "u",         mods = "CTRL|SHIFT",     action = act.CharSelect, },
  { key = "x",         mods = "CTRL|SHIFT",     action = act.ActivateCopyMode, },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "CTRL|SHIFT",
    action = act.ActivatePaneByIndex(i - 1),
  })
end

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "SUPER",
    action = act.ActivateTab(i - 1),
  })
end

table.insert(config.keys, {
  key = "F12",
  mods = "NONE",
  action = act.Multiple {
    (act.ActivateKeyTable {
      name = "cancel",
      replace_current = true,
    }),
    act.EmitEvent "toggle-leader",
  },
})

wezterm.on("toggle-leader", function(window, pane, ...)
  local overrides = window:get_config_overrides() or {}
  if not overrides.leader then
    wezterm.emit("enable-leader", window, pane, ...)
  else
    wezterm.emit("disable-leader", window, pane, ...)
  end
end)

wezterm.on("enable-leader", function(window, pane, ...)
  local overrides = window:get_config_overrides() or {}
  -- replace it with an "impossible" leader that will never be pressed
  overrides.leader = { key = "_", mods = "CTRL|ALT|SUPER" }
  overrides.colors = { background = "#100000" }
  overrides.window_background_opacity = 0.95
  window:set_config_overrides(overrides)
  window.perform_action(act.ActivateKeyTable { name = "cancel", }, pane)
end)

wezterm.on("disable-leader", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  -- restore to the main leader
  overrides.leader = nil
  overrides.colors = nil
  overrides.window_background_opacity = nil
  window:set_config_overrides(overrides)
  window.perform_action(act.ClearKeyTableStack, pane)
end)

wezterm.on("cancel-key-tables", function(window, pane)
  wezterm.emit("disable-leader", window, pane)
  window.perform_action(act.ClearKeyTableStack, pane)
end)

config.key_tables = config.key_tables or {}
config.key_tables.cancel = {
  { key = "c",      mods = "CTRL", action = act.Multiple { act.PopKeyTable, act.EmitEvent "cancel-leader", } },
  { key = "g",      mods = "CTRL", action = act.Multiple { act.PopKeyTable, act.EmitEvent "cancel-leader", } },
  { key = "Escape", mods = "NONE", action = act.Multiple { act.PopKeyTable, act.EmitEvent "cancel-leader", } },
}

-- (utils.KeyTable.new {
--   name = "window",
--   key = "w",
--   mods = "LEADER",
--   {
--     k = act.CloseCurrentTab { confirm = true },
--   }
-- }).apply_to_config(config)

-- config.key_tables = {
--   -- window = {
--   --   { key = "d", action = act.CloseCurrentTab { confirm = true } },
--   -- },
--   resize_pane = {
--     { key = 'h',          action = act.AdjustPaneSize { 'Left', 5 } },
--     { key = 'l',          action = act.AdjustPaneSize { 'Right', 5 } },
--     { key = 'k',          action = act.AdjustPaneSize { 'Up', 5 } },
--     { key = 'j',          action = act.AdjustPaneSize { 'Down', 5 } },
--     { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 5 } },
--     { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 5 } },
--     { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 5 } },
--     { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 5 } },
--     { key = 'Space',      action = act.Multiple { act.TogglePaneZoomState, act.PopKeyTable } },
--   },
--   activate_pane = {
--     { key = 'h',          action = act.ActivatePaneDirection 'Left' },
--     { key = 'l',          action = act.ActivatePaneDirection 'Right' },
--     { key = 'k',          action = act.ActivatePaneDirection 'Up' },
--     { key = 'j',          action = act.ActivatePaneDirection 'Down' },
--
--     { key = 'LeftArrow',  action = act.ActivatePaneDirection 'Left' },
--     { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
--     { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
--     { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },
--   },
-- }

config.launch_menu = {
  {
    label = "dotfiles: edit",
    args = { "zsh", "-c", "nvim", ".dotfiles", "+cd %:p:h", "+Telescope find_files" },
  }
}

-- wezterm.plugin
--     .require('https://github.com/mrjones2014/smart-splits.nvim')
--     .apply_to_config(config, {
--       modifiers = {
--         move = 'CTRL|SHIFT',
--         resize = 'CTRL|SHIFT|SUPER',
--       },
--     })

-- wezterm.plugin
--     .require('https://github.com/MLFlexer/modal.wezterm')
--     .apply_to_config(config, {})

local workspace_switcher = wezterm.plugin
    .require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

workspace_switcher.apply_to_config(config)

-- wezterm.log_info(config)

return config
