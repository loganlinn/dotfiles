local wezterm = require("wezterm")
-- local start_time = wezterm.time.now()

local config = wezterm.config_builder()
config:set_strict_mode(true)
config.debug_key_events = false
config.automatically_reload_config = true
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = "CursorColor",
}
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "0.5cell",
  bottom = "0.5cell",
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
config.use_fancy_tab_bar = false -- do not use native ui
config.window_decorations = "RESIZE"
config.command_palette_rows = 10
config.exit_behavior = "CloseOnCleanExit" -- Use 'Hold' to not close
config.exit_behavior_messaging = "Terse"
config.quit_when_all_windows_are_closed = true
config.switch_to_last_active_tab_when_closing_tab = true
config.check_for_updates = false
config.hide_tab_bar_if_only_one_tab = false
config.native_macos_fullscreen_mode = false
config.hyperlink_rules = {
  {
    format = "$1",
    highlight = 1,
    regex = "\\((\\w+://\\S+)\\)",
  },
  {
    format = "$1",
    highlight = 1,
    regex = "\\[(\\w+://\\S+)\\]",
  },
  {
    format = "$1",
    highlight = 1,
    regex = "<(\\w+://\\S+)>",
  },
  {
    format = "$0",
    highlight = 0,
    regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
  },
  {
    format = "https://linear.app/gamma-app/issue/$1",
    highlight = 1,
    regex = "\\b([gG]-\\d+)\\b",
  },
  {
    regex = [[error: could not format file ([^:]+):.+starting from line (\d+).+character (\d+).+ending on line (\d+).+character (\d+)]],
    format = [[file://$1#$2.$3:$4.$5]],
    highlight = 1,
  },
}
config.quick_select_patterns = {
  "[\\h]{7,40}", -- SHA1 hashes, usually used for Git.
  "[\\h]{7,64}", -- SHA256 hashes, used often for getting hashes for Guix packaging.
  "sha256-.{44,128}", -- SHA256 hashes in Base64, used often in getting hashes for Nix packaging.
  "sha512-.{44,128}", -- SHA512 hashes in Base64, used often in getting hashes for Nix packaging.
  "'nix [^']+.drv'", -- single quoted strings
  [[(?:[-._~/a-zA-Z0-9])*[/ ](?:[-._~/a-zA-Z0-9]+)]], -- unix paths
  "(?<= | | | | | | | | | | | | | |󰢬 | | | |└──|├──)\\s?(\\S+)", -- lsd/eza output.
  -- alternative impl for above regex: code point ranges for glyph sets:
  -- https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points#overview
}
for _, pattern in ipairs(wezterm.default_hyperlink_rules()) do
  table.insert(config.quick_select_patterns, pattern.regex)
end

require("dotfiles.keys").apply_to_config(config)
if not config.keys or #config.keys == 0 then
  config.keys = config.keys or {}
  wezterm.log_error("No keys configured!")
  table.insert(config.keys, { mods = "SUPER", key = "F1", action = wezterm.action.ShowDebugOverlay })
  table.insert(config.keys, { mods = "SUPER", key = "F5", action = wezterm.action.ReloadConfiguration })
  table.insert(
    config.keys,
    { mods = "SUPER", key = "w", action = wezterm.action.CloseCurrentPane({ confirm = false }) }
  )
end

wezterm.on("open-uri", function(window, pane, uri)
  local url = wezterm.url.parse(uri)
  wezterm.log_info("parsed url", url)

  if url.scheme == "file" then
    -- window:perform_action(
    --   act.SpawnCommandInNewTab({
    --     cwd = util.dirname(url.file_path),
    --     args = { "zsh", "-c", 'yazi "$1"', "zsh", url.file_path },
    --     -- args = { "yazi", url.file_path },
    --   }),
    --   pane
    -- )

    wezterm.open_with(uri, "WezTerm")
    return false
  else
    wezterm.open_with(uri)
  end
end)

-- zen-mode.nvim integration
-- https://github.com/folke/zen-mode.nvim/blob/29b292bdc58b76a6c8f294c961a8bf92c5a6ebd6/README.md#wezterm
wezterm.on("user-var-changed", function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while number_value > 0 do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = true
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end
  window:set_config_overrides(overrides)
end)

require("dotfiles.font").apply_to_config(config)
require("dotfiles.tabline").apply_to_config(config)
require("dotfiles.balance").apply_to_config(config)

-- wezterm.log_info("FINISH", "wezterm.lua", "elapsed: " .. require("dotfiles.util").time_diff_ms(wezterm.time.now(), start_time) .. " ms")

return config
