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
  --   key = "w",
  --   mods = "CTRL",
  --   timeout_milliseconds = math.maxinteger,
  -- }
  -- config.keys = {
  --   {
  --     key = "h",
  --     mods = "LEADER",
  --     action = action.ActivatePaneDirection("Left"),
  --   },
  --   {
  --     key = "j",
  --     mods = "LEADER",
  --     action = action.ActivatePaneDirection("Down"),
  --   },
  --   {
  --     key = "k",
  --     mods = "LEADER",
  --     action = action.ActivatePaneDirection("Up"),
  --   },
  --   {
  --     key = "l",
  --     mods = "LEADER",
  --     action = action.ActivatePaneDirection("Right"),
  --   },
  --   {
  --     key = "-",
  --     mods = "LEADER",
  --     action = action.ActivatePaneDirection("Right"),
  --   },
  --   {
  --     key = "Enter",
  --     mods = "LEADER",
  --     action = action.ActivatePaneDirection("Right"),
  --   },
  -- }

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
