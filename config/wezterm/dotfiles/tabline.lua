local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local info, warn = wezterm.log_info, wezterm.log_warn
local nerdfonts = wezterm.nerdfonts ---@cast table<string, string>
local util = require("dotfiles.util")

local custom_components = {}

-- Helper to ensure component configured for window
local function window_component(callback)
  return function(window, ...)
    if not window or not window.window_id then
      warn("expected window argument, got", window)
      return ""
    end
    return callback(window, ...)
  end
end

local function active_key_table(window)
  local scheme = tabline.get_colors().scheme
  local key_table = window:active_key_table()
  if key_table then
    return wezterm.format({
      { Background = { Color = scheme.ansi[6] } },
      { Foreground = { Color = scheme.ansi[1] } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. key_table .. " " .. wezterm.nerdfonts.cod_layers_dot .. "  " },
      "ResetAttributes",
    })
  else
    return wezterm.format({
      { Foreground = { Color = scheme.tab_bar.inactive_tab.fg_color } },
      { Text = " " .. wezterm.nerdfonts.cod_layers .. "  " },
      "ResetAttributes",
    })
  end
end

-- Leader key status
function custom_components.leader()
  -- local leader_text = " LEADER "
  local leader_text = " " .. wezterm.nerdfonts.md_home_floor_l .. "  "

  -- memoizes to avoid recomputing identical style strings
  local leader_active = util.delay(function()
    local scheme = tabline.get_colors().scheme
    return wezterm.format({
      { Background = { Color = scheme.ansi[7] } },
      { Foreground = { Color = scheme.ansi[1] } },
      { Attribute = { Intensity = "Bold" } },
      { Text = leader_text },
      "ResetAttributes",
    })
  end)

  local leader_inactive = util.delay(function()
    local scheme = tabline.get_colors().scheme
    return wezterm.format({
      { Foreground = { Color = scheme.tab_bar.inactive_tab.fg_color } },
      { Text = leader_text },
      "ResetAttributes",
    })
  end)

  return window_component(function(window)
    if window:leader_is_active() then
      return leader_active()
    else
      return leader_inactive()
    end
  end)
end

custom_components.active_tab = window_component(function(window)
  local tab = window:active_tab()
  local tab_title = tab:get_title()
  if not tab_title or #tab_title == 0 then
    tab_title = "#" .. tostring(tab:tab_id())
  end
  return string.format(" %s ", tab_title)
end)

function custom_components.config_reload_count()
  local state = util.event_counter("window-config-reloaded")
  return function(_)
    return string.format(" v%d ", state:deref())
  end
end

tabline.setup({
  options = {
    icons_enabled = false,
    section_separators = {
      left = nerdfonts.pl_left_hard_divider,
      right = nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = nerdfonts.pl_left_soft_divider,
      right = "", -- nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = nerdfonts.pl_left_hard_divider,
      right = nerdfonts.pl_right_hard_divider,
    },
    padding = 1,
    color_overrides = {
      normal_mode = {
        b = { bg = "#6272A4", fg = "#F8F8F2" }, -- different color workspace name (prob a better place to set this)
      },
    },
  },
  sections = {
    tabline_a = { "mode" },
    tabline_b = {
      { Attribute = { Intensity = "Bold" } },
      "workspace",
    },
    tabline_c = {},
    tab_active = {
      "index",
      { "cwd", padding = { left = 0, right = 1 } },
      { "process", padding = 1, icons_enabled = true, icons_only = true },
      { "zoomed", padding = 0 },
    },
    tab_inactive = {
      "index",
      { "cwd", padding = { left = 0, right = 1 } },
      { "process", padding = 1, icons_enabled = true, icons_only = true },
      { "zoomed", padding = 0 },
    },
    tabline_x = {
      active_key_table,
      " ",
      custom_components.leader(),
      " ",
      custom_components.config_reload_count(),
      " ",
    },
    tabline_y = {
      custom_components.active_tab,
      "window",
    },
    tabline_z = {
      "datetime",
      -- "hostname",
    },
  },
})

return tabline
