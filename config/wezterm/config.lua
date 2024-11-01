local wezterm = require 'wezterm'
local log_info = wezterm.log_info
local log_warn = wezterm.log_warn
local log_error = wezterm.log_error
local act = wezterm.action
local mux = wezterm.mux

-- local starts_with = function(str, start) return str:sub(1, #start) == start end
-- local ends_with = function(str, ending) return ending == "" or str:sub(- #ending) == ending end
-- local is_darwin = ends_with(wezterm.target_triple, "apple-darwin")
-- local is_linux = ends_with(wezterm.target_triple, "linux-gnu")
-- local is_windows = ends_with(wezterm.target_triple, "windows-msvc")

local MOD_KEYS = { "SUPER", "CMD", "WIN", "CTRL", "SHIFT", "ALT", "OPT", "META", "LEADER" }

local Key = {}
function Key:new(mods, keys, action)
  local obj = {
    mods = mods,
    keys = keys,
    action = action
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end

local function insert_cancel_keys(tbl, action)
  table.insert(tbl, { key = "Escape", action = action })
  table.insert(tbl, { key = "q", action = action })
  table.insert(tbl, { mods = 'CTRL', key = "c", action = action })
  table.insert(tbl, { mods = 'CTRL', key = "g", action = action })
  return tbl
end

-- local key_direction_mapping = { h = "Left", j = "Down", k = "Up", l = "Right" }

-------------------------------------------------------------------------------
--- config reference: https://wezfurlong.org/wezterm/config/lua/config

return function(config)
  config:set_strict_mode(true)

  config.color_scheme = "Dracula" -- github.com/dracula/wezterm
  config.font = wezterm.font_with_fallback {
    {
      family = "Victor Mono",
      weight = "Regular",
      harfbuzz_features = {
        -- "ss01", -- Single-storey a
        "ss02", -- Slashed zero, variant 1
        -- "ss03", -- Slashed zero, variant 2
        -- "ss04", -- Slashed zero, variant 3
        -- "ss05", -- Slashed zero, variant 4
        -- "ss06", -- Slashed seven
        "ss07", -- Straighter 6 and 9
        -- "ss08", -- More fishlike turbofish (previous default ::< ligature)
      }
    },
    "Cascadia Code",
    "JetBrains Mono",
    "Courier New",
  }
  config.font_size = 14
  config.cell_width = 1
  config.line_height = 1.1
  config.command_palette_font_size = config.font_size
  -- config.command_palette_bg_color = TODO
  -- config.command_palette_fg_color = TODO
  config.command_palette_font_size = config.font_size
  config.command_palette_rows = 10
  config.window_frame = {
    font = config.font
  }
  config.bold_brightens_ansi_colors = "BrightAndBold";

  config.adjust_window_size_when_changing_font_size = false
  config.enable_scroll_bar = true
  config.exit_behavior = "CloseOnCleanExit" -- Use 'Hold' to not close
  config.quit_when_all_windows_are_closed = true
  config.switch_to_last_active_tab_when_closing_tab = true
  config.check_for_updates = false
  config.hide_tab_bar_if_only_one_tab = true
  config.initial_cols = 140
  config.initial_rows = 70
  config.native_macos_fullscreen_mode = false
  config.tab_bar_at_bottom = true
  config.use_fancy_tab_bar = false -- do not use native ui
  config.window_decorations = "RESIZE"
  config.selection_word_boundary = '{}[]()"\'`.,;:'
  config.enable_kitty_keyboard = true --  honor kitty keyboard protocol escape sequences that modify the keyboard encoding
  -- config.disable_default_key_bindings = true

  -- config.leader = {
  --   key = ";",
  --   mods = "CTRL|SHIFT",
  --   timeout_milliseconds = math.maxinteger,
  -- }
  config.use_ime = false
  config.use_dead_keys = false
  config.debug_key_events = false

  config.keys = {
    {
      key = 'F1',
      action = act.ShowDebugOverlay,
    },
    {
      key = "f",
      mods = "SUPER",
      action = act.Search { CaseSensitiveString = "" },
    },
    {
      key = "Enter",
      mods = "CTRL|SHIFT",
      action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
    },
    {
      key = "Enter",
      mods = "CTRL|SHIFT|SUPER",
      action = act.SplitVertical { domain = "CurrentPaneDomain" },
    },
    {
      key = "Space",
      mods = "CTRL|SHIFT",
      action = act.QuickSelect,
    },
    {
      key = "Home",
      mods = "CTRL|SHIFT",
      action = act.ScrollToTop,
    },
    {
      key = "PageUp",
      mods = "CTRL|SHIFT",
      action = act.ScrollByPage(-1),
    },
    {
      key = "PageDown",
      mods = "CTRL|SHIFT",
      action = act.ScrollByPage(1),
    },
    {
      key = "End",
      mods = "CTRL|SHIFT",
      action = act.ScrollToBottom,
    },
    {
      key = "<",
      mods = "CTRL|SHIFT",
      action = act.MoveTabRelative(-1),
    },
    {
      key = ">",
      mods = "CTRL|SHIFT",
      action = act.MoveTabRelative(1),
    },
    {
      key = "h",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Left"),
    },
    {
      key = "j",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Down"),
    },
    {
      key = "k",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Up"),
    },
    {
      key = "l",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Right"),
    },
    {
      key = "t",
      mods = "CTRL|SHIFT",
      action = act.SpawnTab 'CurrentPaneDomain'
    },
    {
      key = "w",
      mods = "CTRL|SHIFT",
      action = act.CloseCurrentPane { confirm = false },
    },
    {
      key = "p",
      mods = "CTRL|SHIFT",
      action = act.ActivateCommandPalette,
    },
    {
      key = "Semicolon",
      mods = "CTRL|SHIFT",
      action = act.ShowLauncher,
    },
    {
      key = "c",
      mods = "CTRL|SHIFT",
      action = act.CopyTo "Clipboard",
    },
    {
      key = "v",
      mods = "CTRL|SHIFT",
      action = act.PasteFrom "Clipboard",
    },
    {
      key = "x",
      mods = "CTRL|SHIFT",
      action = act.ActivateCopyMode,
    },
    {
      key = "u",
      mods = "CTRL|SHIFT",
      action = act.CharSelect,
    },
    {
      key = "f",
      mods = "CTRL|SHIFT",
      action = act.RotatePanes 'Clockwise'
    },
    {
      key = "b",
      mods = "CTRL|SHIFT",
      action = act.RotatePanes 'CounterClockwise'
    },
    {
      key = 'h',
      mods = 'CTRL|SHIFT|ALT',
      action = act.AdjustPaneSize { 'Left', 5 },
    },
    {
      key = 'j',
      mods = 'CTRL|SHIFT|ALT',
      action = act.AdjustPaneSize { 'Down', 5 },
    },
    {
      key = 'k',
      mods = 'CTRL|SHIFT|ALT',
      action = act.AdjustPaneSize { 'Up', 5 },
    },
    {
      key = 'l',
      mods = 'CTRL|SHIFT|ALT',
      action = act.AdjustPaneSize { 'Right', 5 },
    },
    {
      key = 'z',
      mods = 'CTRL|SHIFT',
      action = act.TogglePaneZoomState,
    },
  }

  for i = 1, 9 do
    table.insert(config.keys, {
      key = tostring(i),
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneByIndex(i - 1),
    })
  end

  config.key_tables = {
    -- Defines the keys that are active in our resize-pane mode.
    -- Since we're likely to want to make multiple adjustments,
    -- we made the activation one_shot=false. We therefore need
    -- to define a key assignment for getting out of this mode.
    -- 'resize_pane' here corresponds to the name="resize_pane" in
    -- the key assignments above.
    resize_pane = {
      { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
      { key = 'h',          action = act.AdjustPaneSize { 'Left', 1 } },

      { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
      { key = 'l',          action = act.AdjustPaneSize { 'Right', 1 } },

      { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
      { key = 'k',          action = act.AdjustPaneSize { 'Up', 1 } },

      { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
      { key = 'j',          action = act.AdjustPaneSize { 'Down', 1 } },

      { key = 'Space',      action = act.Multiple { act.TogglePaneZoomState, act.PopKeyTable } },
    },

    -- Defines the keys that are active in our activate-pane mode.
    -- 'activate_pane' here corresponds to the name="activate_pane" in
    -- the key assignments above.
    activate_pane = {
      { key = 'LeftArrow',  action = act.ActivatePaneDirection 'Left' },
      { key = 'h',          action = act.ActivatePaneDirection 'Left' },

      { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
      { key = 'l',          action = act.ActivatePaneDirection 'Right' },

      { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
      { key = 'k',          action = act.ActivatePaneDirection 'Up' },

      { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },
      { key = 'j',          action = act.ActivatePaneDirection 'Down' },
    },
  }

  -- config.launch_menu = {
  --   {
  --     args = { 'top' },
  --   },
  --   {
  --     -- Optional label to show in the launcher. If omitted, a label
  --     -- is derived from the `args`
  --     label = 'Bash',
  --     -- The argument array to spawn.  If omitted the default program
  --     -- will be used as described in the documentation above
  --     args = { 'bash', '-l' },

  --     -- You can specify an alternative current working directory;
  --     -- if you don't specify one then a default based on the OSC 7
  --     -- escape sequence will be used (see the Shell Integration
  --     -- docs), falling back to the home directory.
  --     -- cwd = "/some/path"

  --     -- You can override environment variables just for this command
  --     -- by setting this here.  It has the same semantics as the main
  --     -- set_environment_variables configuration option described above
  --     -- set_environment_variables = { FOO = "bar" },
  --   },
  -- }
end
