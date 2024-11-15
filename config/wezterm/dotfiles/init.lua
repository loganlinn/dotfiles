local wezterm = require("wezterm") -- https://wezfurlong.org/wezterm/config/lua/config
local utils = require("dotfiles.utils")

local config = wezterm.config_builder()
config:set_strict_mode(true)

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

config.font = victor_mono({ style = "Normal" })
config.font_size = 14
config.cell_width = 1
config.line_height = 1.1
config.font_rules = {
  { italic = true, font = victor_mono({ style = "Oblique" }) },
}
-- config.freetype_load_target = "Light"

config.default_cursor_style = "BlinkingBar"

config.window_frame = { font = config.font }
config.window_padding = {
  right = "1cell",
  left = "1cell",
}
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.8,
}
config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = "BrightAndBold"
config.enable_scroll_bar = true
config.initial_cols = 140
config.initial_rows = 70
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false -- do not use native ui
config.window_decorations = "RESIZE"

---@return string Text representation of key assignment
local function keystr(key_assignment)
  if (key_assignment.mod or "NONE") ~= "NONE" then
    return string.format("%s+%s", key_assignment.key, key_assignment.mods)
  end
  return key_assignment.key
end

wezterm.on("update-right-status", function(window, pane)
  local cfg = window:effective_config()
  local color = cfg.color_schemes[cfg.color_scheme]
  -- wezterm.log_info(color)

  local status = {}

  local active_key_table = window:active_key_table()
  if active_key_table then
    table.insert(status, { Foreground = { AnsiColor = "Fuchsia" } })
    table.insert(status, { Attribute = { Intensity = "Bold" } })
    table.insert(status, { Text = string.format(" %s ", active_key_table) })
    table.insert(status, { Attribute = { Intensity = "Normal" } })
    table.insert(status, {
      Text = string.format(
        "[%s]",
        table.concat(
          utils.tbl.map(function(_, v)
            return v.key
          end, cfg.key_tables[active_key_table]),
          "|"
        )
      ),
    })
    table.insert(status, "ResetAttributes")
    table.insert(status, { Text = " " })
  end

  if window:leader_is_active() then
    table.insert(status, { Foreground = { Color = "black" } })
    table.insert(status, { Background = { Color = "green" } })
  else
    table.insert(status, { Foreground = { Color = "grey" } })
  end
  table.insert(status, { Text = " LEADER " })
  table.insert(status, "ResetAttributes")
  table.insert(status, { Text = " " })

  for i, workspace_name in pairs(wezterm.mux.get_workspace_names()) do
    if workspace_name == window:active_workspace() then
      table.insert(status, { Background = { Color = color.brights[1] } })
    end
    table.insert(status, { Text = string.format(" %d: %s ", i, workspace_name) })
    table.insert(status, "ResetAttributes")
  end
  window:set_right_status(wezterm.format(status))
end)

config.command_palette_font_size = config.font_size
config.command_palette_font_size = config.font_size
config.command_palette_rows = 10
-- config.command_palette_bg_color = TODO
-- config.command_palette_fg_color = TODO

config.exit_behavior = "CloseOnCleanExit" -- Use 'Hold' to not close
config.quit_when_all_windows_are_closed = true
config.switch_to_last_active_tab_when_closing_tab = true
config.check_for_updates = false
config.hide_tab_bar_if_only_one_tab = false
config.native_macos_fullscreen_mode = false
-- config.selection_word_boundary = '{}[]()"\'`.,;:'

-- config.debug_key_events = true
config.disable_default_key_bindings = true
config.enable_kitty_keyboard = true
config.leader = {
  mods = "CTRL|SHIFT",
  key = "Space",
  timeout_milliseconds = math.maxinteger,
}

local act = wezterm.action
config.keys = {
  -- Tab Focus
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

  -- Tab Position
  { key = "<", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
  { key = ">", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },

  -- Pane Lifecycle
  { key = "Enter", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "Enter", mods = "CTRL|SHIFT|SUPER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "w", mods = "SUPER", action = act.CloseCurrentPane({ confirm = true }) },

  -- Window Lifecycle
  { key = "n", mods = "SUPER", action = act.SpawnWindow },
  {
    key = "N",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine({
      description = wezterm.format({
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Enter name for new workspace" },
      }),
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:perform_action(
            act.SwitchToWorkspace({
              name = line,
            }),
            pane
          )
        end
      end),
    }),
  },

  -- Workspace
  { key = "{", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
  { key = "}", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(1) },
  { key = "Backslash", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

  -- Tabs
  {
    key = "F2",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine({
      description = "Tab name",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- Pane Focus
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

  -- Pane Size
  { key = "h", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "j", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "k", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "l", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- Pane Misc
  { key = "b", mods = "CTRL|SHIFT", action = act.RotatePanes("CounterClockwise") },
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

  -- Scroll
  { key = "Home", mods = "CTRL|SHIFT", action = act.ScrollToTop },
  { key = "PageDown", mods = "CTRL|SHIFT", action = act.ScrollByPage(1) },
  { key = "PageUp", mods = "CTRL|SHIFT", action = act.ScrollByPage(-1) },
  { key = "End", mods = "CTRL|SHIFT", action = act.ScrollToBottom },

  -- System
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- Selection
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
  { key = "f", mods = "CTRL|SHIFT", action = act.QuickSelect },

  -- Misc
  { key = "F1", mods = "SUPER", action = act.ShowDebugOverlay },
  { key = "f", mods = "SUPER", action = act.Search({ CaseSensitiveString = "" }) },
  { key = "Semicolon", mods = "CTRL|SHIFT", action = act.ShowLauncher },
  { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
  { key = "u", mods = "CTRL|SHIFT", action = act.CharSelect },
  { key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },

  { key = "m", mods = "CTRL|SHIFT", action = act.ActivateKeyTable({ name = "mux" }) },
  { key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "mux" }) },
  { key = "w", mods = "LEADER", action = act.ActivateKeyTable({ name = "window" }) },
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

config.key_tables = {
  mux = {
    {
      key = "r",
      mods = "NONE",
      action = act.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Text = "Enter name for new workspace" },
        }),
        action = wezterm.action_callback(function(window, pane, input)
          if input then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), input)
          end
        end),
      }),
    },
    -- Cancel
    { key = "Escape", mods = "NONE", action = act.ClearKeyTableStack },
    { key = "g", mods = "CTRL", action = act.ClearKeyTableStack },
    { key = "c", mods = "CTRL", action = act.ClearKeyTableStack },
  },
  window = {
    { key = "d", action = act.CloseCurrentTab({ confirm = true }) },
    { key = "s", action = act.PaneSelect({ mode = "SwapWithActive" }) },
    -- Cancel
    { key = "Escape", mods = "NONE", action = act.ClearKeyTableStack },
    { key = "g", mods = "CTRL", action = act.ClearKeyTableStack },
    { key = "c", mods = "CTRL", action = act.ClearKeyTableStack },
  },
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
}

config.launch_menu = {
  {
    label = "dotfiles: edit",
    args = { "zsh", "-c", "nvim", ".dotfiles", "+cd %:p:h", "+Telescope find_files" },
  },
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

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

workspace_switcher.apply_to_config(config)

-- wezterm.log_info(config)

return config
