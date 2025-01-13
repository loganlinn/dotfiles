local wezterm = require("wezterm")
local util = require("dotfiles.util")
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
  local tab2 = window:spawn_tab({
    cwd = prj_root .. "packages/event-tracking",
  })
  tab2:active_pane():send_text("nvim\n")
  -- window:spawn_tab({
  --   cwd = prj_root .. "packages/server",
  -- })
  -- window:spawn_tab({
  --   cwd = prj_root .. "packages/client",
  -- })
  -- window:spawn_tab({
  --   cwd = prj_root .. "packages/hocuspocus",
  -- })
end

wezterm.on("gui-startup", function(cmd)
  log.info(cmd)
  -- if cmd then
  --   spawn_window(cmd)
  --   return
  -- end
  start_dotfiles()
  start_gamma()
  set_active_workspace("gamma")
end)
