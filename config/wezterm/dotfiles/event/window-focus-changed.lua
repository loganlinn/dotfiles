local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("dotfiles.event.window-focus-changed")

wezterm.on("window-focus-changed", function(window, pane)
  local mux_window = window:mux_window()
  local workspace = mux_window:get_workspace()
  local domain = pane:get_domain_name()

  log.info("window:", window, "pane:", pane, "workspace:", workspace, "domain:", domain)

  -- if domain == "TermWizTerminalDomain" then
  --   log.info("detected wezterm configuration error window")
  --   window:perform_action(wezterm.action.ToggleAlwaysOnTop, pane)
  --   mux_window:set_title(domain)
  --   -- window:set_config_overrides({
  --   --   color_scheme = "GruvboxLight",
  --   --   always_on_top_auto_hide = false,
  --   -- })
  -- end
end)
