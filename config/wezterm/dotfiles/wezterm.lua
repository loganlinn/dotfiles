local wezterm = require("wezterm")

local config = wezterm.config_builder()

config:set_strict_mode(true)

require("dotfiles.event").apply_to_config(config)
require("dotfiles.keys").apply_to_config(config)
require("dotfiles.domains").apply_to_config(config)
require("dotfiles.launch_menu").apply_to_config(config)
require("dotfiles.ressurect").apply_to_config(config)
require("dotfiles.tabline").apply_to_config(config)
require("dotfiles.balance").apply_to_config(config)
require("dotfiles.font").apply_to_config(config)
require("dotfiles.gui").apply_to_config(config)
require("dotfiles.patterns").apply_to_config(config)

-- wezterm.plugin.update_all()

return config
