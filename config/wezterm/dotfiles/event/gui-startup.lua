local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("dotfiles.event.gui-startup")

local set_active_workspace = wezterm.mux.set_active_workspace
local get_window = wezterm.mux.get_window
local spawn_window = function(cmd)
  log.info("spawn_window", cmd)
  return wezterm.mux.spawn_window(cmd)
end

local function start_dotfiles()
  local tab, pane, window = spawn_window({
    workspace = "dotfiles",
    cwd = wezterm.home_dir .. "/src/github.com/loganlinn/dotfiles",
  })
  pane:split({
    direction = "Right",
    size = 0.3,
  })
end

local function start_gamma()
  local prj_root = wezterm.home_dir .. "/src/github.com/gamma-app/gamma/"
  local env = {}
  local tab1, pane, window = spawn_window({
    workspace = "gamma",
    cwd = prj_root,
  })
  window
    :spawn_tab({
      cwd = prj_root .. "packages/event-tracking",
    })
    :active_pane()
    :send_text("$EDITOR\n")
end

wezterm.on("gui-startup", function(cmd)
  log.info(cmd)
  if not cmd then
    start_dotfiles()
    start_gamma()
    set_active_workspace("gamma")
  end
end)
