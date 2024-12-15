local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local info, warn = wezterm.log_info, wezterm.log_warn
local nerdfonts = wezterm.nerdfonts ---@cast table<string, string>
local util = require("dotfiles.util")

local function active_key_table()
  return function(window)
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
end

local function leader_key()
  local leader_text = " " .. wezterm.nerdfonts.md_home_floor_l .. " "

  -- cache static text formats
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

  return function(window)
    if window:leader_is_active() then
      return leader_active()
    else
      return leader_inactive()
    end
  end
end

local function active_tab()
  return function(window)
    local tab = window:active_tab()
    local tab_title = tab:get_title()
    if not tab_title or #tab_title == 0 then
      tab_title = "#" .. tostring(tab:tab_id())
    end
    return string.format(" %s ", tab_title)
  end
end

local function config_reload_count()
  local state = util.event_counter("window-config-reloaded")
  return function(_)
    local scheme = tabline.get_colors().scheme
    return wezterm.format({
      { Foreground = { Color = scheme.ansi[#scheme.ansi] } },
      { Text = string.format(" v%d ", state:deref()) },
      "ResetAttributes",
    })
  end
end

local zoomed = {
  "zoomed",
  padding = 1,
  fmt = function(str)
    if #(str or "") then
      return wezterm.nerdfonts.cod_expand_all
    end
  end,
}

tabline.setup({
  options = {
    icons_enabled = false,
    section_separators = {
      left = nerdfonts.pl_left_hard_divider,
      right = nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = "", -- nerdfonts.pl_left_soft_divider,
      right = "", -- nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = "", -- nerdfonts.pl_left_hard_divider,
      right = "", -- nerdfonts.pl_right_hard_divider,
    },
    padding = 1,
    color_overrides = {
      normal_mode = {
        b = { bg = "#6272A4", fg = "#F8F8F2" }, -- different color workspace name (prob a better place to set this)
      },
    },
  },
  sections = {
    tabline_a = {
      { "mode", padding = 2 },
    },
    tabline_b = {
      -- { Attribute = { Intensity = "Bold" } },
      { "workspace", padding = 2 },
    },
    tabline_c = {
      " ",
    },
    tab_active = {
      -- { "index", padding = { left = 3, right = 0 } },
      -- { "cwd", padding = { left = 1, right = 1 } },
      -- { "process", padding = { left = 1, right = 3 }, icons_enabled = true, icons_only = true },
      { "index", padding = { left = 4 } },
      { Attribute = { Intensity = "Bold" } },
      "cwd",
      { "zoomed", icons_enabled = true, icons_only = true, padding = 0 },
      "   ",
    },
    tab_inactive = {
      -- { "cwd", padding = { left = 0, right = 1 } },
      -- { "process", padding = 1, icons_enabled = true, icons_only = true },
      { "index", padding = { left = 4 } },
      { Attribute = { Intensity = "Half" } },
      "cwd",
      { "zoomed", icons_enabled = true, icons_only = true, padding = 0 },
      "   ",
    },
    tabline_x = {
      config_reload_count(),
      active_key_table(),
      leader_key(),
      " ",
    },
    tabline_y = {
      -- active_tab(),
      { "window", padding = 2 },
    },
    tabline_z = {
      { "datetime", padding = 2 },
      -- "hostname",
    },
  },
})

return tabline
