local wezterm = require 'wezterm'

local info, warn, error = wezterm.log_info, wezterm.log_warn, wezterm.log_error
local action = wezterm.action
local mux = wezterm.mux

-- local starts_with = function(str, start) return str:sub(1, #start) == start end
-- local ends_with = function(str, ending) return ending == "" or str:sub(- #ending) == ending end
--
-- local is_darwin = ends_with(wezterm.target_triple, "apple-darwin")
-- local is_linux = ends_with(wezterm.target_triple, "linux-gnu")
-- local is_windows = ends_with(wezterm.target_triple, "windows-msvc")

return function(config)
  info 'configuring...'

  -- config:set_strict_mode(true)

  config.font = wezterm.font_with_fallback {
    "Victor Mono",
    "Cascadia Code",
    "Fira Code",
    "DejaVu Sans Mono",
    "JetBrains Mono",
    "PT Mono",
    "Courier New",
  }
  config.font_size = 14
  config.cell_width = 1
  config.line_height = 1.1
  config.command_palette_font_size = config.font_size
  config.window_frame = {
    font = config.font
  }

  config.adjust_window_size_when_changing_font_size = false
  config.enable_scroll_bar = true
  config.exit_behavior = "CloseOnCleanExit" -- Use 'Hold' to not close
  config.hide_tab_bar_if_only_one_tab = true
  config.initial_cols = 140
  config.initial_rows = 40
  config.native_macos_fullscreen_mode = false
  config.tab_bar_at_bottom = true
  config.use_fancy_tab_bar = false
  config.window_decorations = "RESIZE"
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
      key = "f",
      mods = "SUPER",
      action = action.Search { CaseSensitiveString = "" },
    },
    {
      key = "Home",
      mods = "CTRL|SHIFT",
      action = action.ScrollToTop,
    },
    {
      key = "PageUp",
      mods = "CTRL|SHIFT",
      action = action.ScrollByPage(-1),
    },
    {
      key = "PageDown",
      mods = "CTRL|SHIFT",
      action = action.ScrollByPage(1),
    },
    {
      key = "End",
      mods = "CTRL|SHIFT",
      action = action.ScrollToBottom,
    },
    -- {
    --   key = "[",
    --   mods = "CTRL|SHIFT",
    --   action = action.ActivateTabRelative(-1),
    -- },
    -- {
    --   key = "]",
    --   mods = "CTRL|SHIFT",
    --   action = action.ActivateTabRelative(1),
    -- },
    {
      key = "<",
      mods = "CTRL|SHIFT",
      action = action.MoveTabRelative(-1),
    },
    {
      key = ">",
      mods = "CTRL|SHIFT",
      action = action.MoveTabRelative(1),
    },
    {
      key = "1",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(0),
    },
    {
      key = "2",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(1),
    },
    {
      key = "3",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(2),
    },
    {
      key = "4",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(3),
    },
    {
      key = "5",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(4),
    },
    {
      key = "6",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(5),
    },
    {
      key = "7",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(6),
    },
    {
      key = "8",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(7),
    },
    {
      key = "9",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(8),
    },
    {
      key = "0",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneByIndex(9),
    },
    {
      key = "h",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneDirection("Left"),
    },
    {
      key = "j",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneDirection("Down"),
    },
    {
      key = "k",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneDirection("Up"),
    },
    {
      key = "l",
      mods = "CTRL|SHIFT",
      action = action.ActivatePaneDirection("Right"),
    },
    {
      key = "t",
      mods = "CTRL|SHIFT",
      action = action.SpawnTab 'CurrentPaneDomain'
    },
    {
      key = "Enter",
      mods = "CTRL|SHIFT",
      action = action.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    },
    {
      key = "w",
      mods = "CTRL|SHIFT",
      action = action.CloseCurrentPane { confirm = false },
    },
    {
      key = "p",
      mods = "CTRL|SHIFT",
      action = action.ActivateCommandPalette,
    },
    {
      key = "Semicolon",
      mods = "CTRL|SHIFT",
      action = action.ShowLauncher,
    },
    {
      key = "c",
      mods = "CTRL|SHIFT",
      action = action.CopyTo "Clipboard",
    },
    {
      key = "v",
      mods = "CTRL|SHIFT",
      action = action.PasteFrom "Clipboard",
    },
    {
      key = "x",
      mods = "CTRL|SHIFT",
      action = action.ActivateCopyMode,
    },
    {
      key = "u",
      mods = "CTRL|SHIFT",
      action = action.CharSelect,
    },
    {
      key = "Space",
      mods = "CTRL|SHIFT",
      action = action.QuickSelect,
    },
    -- {
    --   key = "Space",
    --   mods = "CTRL|SHIFT|ALT",
    --   action = action.QuickSelectArgs {},
    -- },
    {
      key = "f",
      mods = "CTRL|SHIFT",
      action = action.RotatePanes 'Clockwise'
    },
    {
      key = "b",
      mods = "CTRL|SHIFT",
      action = action.RotatePanes 'CounterClockwise'
    },
    {
      key = 'h',
      mods = 'CTRL|SHIFT|ALT',
      action = action.AdjustPaneSize { 'Left', 5 },
    },
    {
      key = 'j',
      mods = 'CTRL|SHIFT|ALT',
      action = action.AdjustPaneSize { 'Down', 5 },
    },
    {
      key = 'k',
      mods = 'CTRL|SHIFT|ALT',
      action = action.AdjustPaneSize { 'Up', 5 },
    },
    {
      key = 'l',
      mods = 'CTRL|SHIFT|ALT',
      action = action.AdjustPaneSize { 'Right', 5 },
    },
    {
      key = 'z',
      mods = 'CTRL|SHIFT',
      action = action.TogglePaneZoomState,
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
