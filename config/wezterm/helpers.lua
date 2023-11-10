local wezterm = require 'wezterm'

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local is_darwin = ends_with(wezterm.target_triple, "apple-darwin")
local is_linux = ends_with(wezterm.target_triple, "linux-gnu")
local is_windows = ends_with(wezterm.target_triple, "windows-msvc")

--------------------------------------------------------------------------------

local module = {}

function module.apply_to_config(config)
  config.color_scheme = "jordan"
  config.font = wezterm.font_with_fallback({ { family = "JetBrainsMono Nerd Font", weight = "Bold" } })
  config.font_size = 12
  config.cell_width = 1
  config.line_height = 1

  config.adjust_window_size_when_changing_font_size = false
  config.native_macos_fullscreen_mode = false
  config.window_decorations = "RESIZE"

-- config.disable_default_key_bindings = true

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

return module
