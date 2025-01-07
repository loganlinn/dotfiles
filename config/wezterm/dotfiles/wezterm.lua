local wezterm = require("wezterm")

local config = wezterm.config_builder()
config:set_strict_mode(true)
require("dotfiles.event").apply_to_config(config)
require("dotfiles.patterns").apply_to_config(config)
require("dotfiles.font").apply_to_config(config)
require("dotfiles.keys").apply_to_config(config)
require("dotfiles.domains").apply_to_config(config, {
  "ssh://nijusan.internal",
  "ssh://wijusan.internal",
  "ssh://logamma.internal",
  "ssh://rpi4b.internal",
  "ssh://rpi400.internal",
  "ssh://pi@fire.walla",
})
require("dotfiles.tabline").apply_to_config(config)
require("dotfiles.balance").apply_to_config(config)
config.window_padding = {
  left = 0, -- "1.2cell",
  right = 0, -- "1.2cell",
  top = 0, -- "0.8cell",
  bottom = 0, --"0.8cell",
}
config.inactive_pane_hsb = {
  saturation = 0.625,
  brightness = 0.750,
}
config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = "BrightAndBold"
config.enable_scroll_bar = true
config.initial_cols = 140
config.initial_rows = 70
config.tab_bar_at_bottom = true
config.tab_max_width = 64
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.command_palette_rows = 10
config.exit_behavior = "CloseOnCleanExit" -- Use 'Hold' to not close
config.exit_behavior_messaging = "Terse"
config.quit_when_all_windows_are_closed = true
config.switch_to_last_active_tab_when_closing_tab = true
config.check_for_updates = false
config.hide_tab_bar_if_only_one_tab = false
config.native_macos_fullscreen_mode = false
return config
