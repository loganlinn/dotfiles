local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  config.launch_menu = config.launch_menu or {}

  -- TODO `gh dash`
  -- TODO `doom update`
  -- TODO `just --justfile $DOTFILES_DIR/justfile --choose`
  -- TODO `just --choose`

  return config
end

return M
