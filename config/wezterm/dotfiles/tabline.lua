local wezterm = require("wezterm")
local nerdfonts = wezterm.nerdfonts
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

local util = require("dotfiles.util")
local basename = util.basename
local dirname = util.dirname
local lpad = function(txt, s)
  s = s or " "
  return s .. txt
end
local rpad = function(txt, s)
  s = s or " "
  return txt .. s
end
local pad = function(txt, l, r)
  return lpad(rpad(txt, r), l)
end

-- https://wezfurlong.org/wezterm/config/lua/color/index.html#available-methods
local C = {}
C.bg = wezterm.color.parse("#282A36")
C.fg = wezterm.color.parse("#F8F8F2")
C.CurrentLine = wezterm.color.parse("#44475A")
C.Comment = wezterm.color.parse("#6272A4")
C.Cyan = wezterm.color.parse("#8BE9FD")
C.Green = wezterm.color.parse("#50FA7B")
C.Orange = wezterm.color.parse("#FFB86C")
C.Pink = wezterm.color.parse("#FF79C6")
C.Purple = wezterm.color.parse("#BD93F9")
C.Red = wezterm.color.parse("#FF5555")
C.Yellow = wezterm.color.parse("#F1FA8C")

local function active_key_table(window)
  local key_table = window:active_key_table()
  local colors = tabline.get_colors()
  local scheme = colors and colors.scheme
  local ansi = scheme and scheme.ansi or {}
  local inactive_fg_color = scheme and scheme.tab_bar.inactive_tab.fg_color or "#111111"
  if key_table then
    return wezterm.format({
      { Background = { Color = ansi[6] } },
      { Foreground = { Color = ansi[1] } },
      { Attribute = { Intensity = "Bold" } },
      { Text = pad(key_table .. " " .. wezterm.nerdfonts.cod_layers_dot) },
      "ResetAttributes",
    })
  else
    return wezterm.format({
      { Foreground = { Color = inactive_fg_color } },
      { Text = " " .. wezterm.nerdfonts.cod_layers .. "  " },
      "ResetAttributes",
    })
  end
end

local function leader_key()
  local leader_text = pad(wezterm.nerdfonts.md_home_floor_l)

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

local tab_label = function(tab)
  local fmt = {
    -- { Text = pad(tostring(tab.tab_index + 1)) },
  }

  local title = tab.tab_title
  if title ~= "" and title ~= "default" then
    return wezterm.format({ { Foreground = { Color = C.Pink } }, { Text = pad(title) }, "ResetAttributes" })
  else
    if tab.active_pane.current_working_dir then
      local cwd = tab.active_pane.current_working_dir.file_path
      local label = basename(cwd)
      local parent = basename(dirname(cwd))
      table.insert(fmt, { Text = " " })
      if parent ~= "." and parent ~= "/" then
        table.insert(fmt, { Foreground = { Color = "#909090" } })
        table.insert(fmt, { Text = parent })
        table.insert(fmt, { Foreground = { AnsiColor = "Grey" } })
        table.insert(fmt, { Text = "/" })
        table.insert(fmt, "ResetAttributes")
      end
      table.insert(fmt, { Foreground = { AnsiColor = "White" } })
      table.insert(fmt, { Text = label })
      table.insert(fmt, { Text = " " })
    elseif tab.active_pane.foreground_process_name then
      table.insert(fmt, { Text = basename(tab.active_pane.foreground_process_name) })
    end
  end

  table.insert(fmt, "ResetAttributes")
  return pad(wezterm.format(fmt))
end

local function config_reload_count()
  local state = util.event_counter("window-config-reloaded")
  return function(_)
    local scheme = tabline.get_colors().scheme
    return wezterm.format({
      { Foreground = { Color = scheme.ansi[#scheme.ansi] } },
      { Text = " v " .. tostring(state:deref()) },
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
local hour_to_icon = {
  ["00"] = wezterm.nerdfonts.md_clock_time_twelve_outline,
  ["01"] = wezterm.nerdfonts.md_clock_time_one_outline,
  ["02"] = wezterm.nerdfonts.md_clock_time_two_outline,
  ["03"] = wezterm.nerdfonts.md_clock_time_three_outline,
  ["04"] = wezterm.nerdfonts.md_clock_time_four_outline,
  ["05"] = wezterm.nerdfonts.md_clock_time_five_outline,
  ["06"] = wezterm.nerdfonts.md_clock_time_six_outline,
  ["07"] = wezterm.nerdfonts.md_clock_time_seven_outline,
  ["08"] = wezterm.nerdfonts.md_clock_time_eight_outline,
  ["09"] = wezterm.nerdfonts.md_clock_time_nine_outline,
  ["10"] = wezterm.nerdfonts.md_clock_time_ten_outline,
  ["11"] = wezterm.nerdfonts.md_clock_time_eleven_outline,
  ["12"] = wezterm.nerdfonts.md_clock_time_twelve_outline,
  ["13"] = wezterm.nerdfonts.md_clock_time_one_outline,
  ["14"] = wezterm.nerdfonts.md_clock_time_two_outline,
  ["15"] = wezterm.nerdfonts.md_clock_time_three_outline,
  ["16"] = wezterm.nerdfonts.md_clock_time_four_outline,
  ["17"] = wezterm.nerdfonts.md_clock_time_five_outline,
  ["18"] = wezterm.nerdfonts.md_clock_time_six_outline,
  ["19"] = wezterm.nerdfonts.md_clock_time_seven_outline,
  ["20"] = wezterm.nerdfonts.md_clock_time_eight_outline,
  ["21"] = wezterm.nerdfonts.md_clock_time_nine_outline,
  ["22"] = wezterm.nerdfonts.md_clock_time_ten_outline,
  ["23"] = wezterm.nerdfonts.md_clock_time_eleven_outline,
}
for k, v in pairs(hour_to_icon) do
  hour_to_icon[k] = { v, color = { fg = C.fg } }
end

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
      { "workspace", padding = 2 },
    },
    tabline_c = {
      "    ",
    },
    tab_active = {
      -- { "index", padding = { left = 3, right = 0 } },
      -- { "cwd", padding = { left = 1, right = 1 } },
      -- { "process", padding = { left = 1, right = 3 }, icons_enabled = true, icons_only = true },
      -- { "index", padding = { left = 4, right = 1 } },
      -- { Attribute = { Intensity = "Bold" } },
      -- "cwd",
      { "index", padding = 1 },
      { Attribute = { Intensity = "Bold" } },
      tab_label,
      { "zoomed", icons_enabled = true, icons_only = true, padding = 0 },
      " ",
    },
    tab_inactive = {
      { "index", padding = 1 },
      { Attribute = { Intensity = "Half" } },
      tab_label,
      { "zoomed", icons_enabled = true, icons_only = true, padding = 0 },
      " ",
    },
    tabline_x = {
      -- config_reload_count(),
      -- active_key_table,
      -- leader_key(),
    },
    tabline_y = {
      {
        "window",
        padding = 2,
        cond = function(window)
          return window:mux_window():get_title() == "default"
        end,
      },
      -- {
      --   "datetime",
      --   padding = 2,
      --   icons_enabled = true,
      --   icons_only = true,
      --   hour_to_icon = hour_to_icon,
      -- },
    },
    tabline_z = {
      {
        "domain",
        icons_enabled = false,
        padding = 2,
        domain_to_icon = {
          default = wezterm.nerdfonts.md_monitor,
          ssh = wezterm.nerdfonts.md_ssh,
          wsl = wezterm.nerdfonts.md_microsoft_windows,
          docker = wezterm.nerdfonts.md_docker,
          unix = wezterm.nerdfonts.cod_terminal_linux,
        },
      },
    },
  },
})

--[[
ansi = [
    '#21222c',
    '#ff5555',
    '#50fa7b',
    '#f1fa8c',
    '#bd93f9',
    '#ff79c6',
    '#8be9fd',
    '#f8f8f2',
]
background = '#282a36'
brights = [
    '#6272a4',
    '#ff6e6e',
    '#69ff94',
    '#ffffa5',
    '#d6acff',
    '#ff92df',
    '#a4ffff',
    '#ffffff',
]
compose_cursor = '#ffb86c'
cursor_bg = '#f8f8f2'
cursor_border = '#f8f8f2'
cursor_fg = '#282a36'
foreground = '#f8f8f2'
scrollbar_thumb = '#44475a'
selection_bg = 'rgba(26.666668% 27.843138% 35.294117% 50%)'
selection_fg = 'rgba(0% 0% 0% 0%)'
split = '#6272a4'

[colors.indexed]

[colors.tab_bar]
background = '#282a36'

[colors.tab_bar.active_tab]
bg_color = '#bd93f9'
fg_color = '#282a36'
intensity = 'Normal'
italic = false
strikethrough = false
underline = 'None'

[colors.tab_bar.inactive_tab]
bg_color = '#282a36'
fg_color = '#f8f8f2'
intensity = 'Normal'
italic = false
strikethrough = false
underline = 'None'

[colors.tab_bar.inactive_tab_hover]
bg_color = '#6272a4'
fg_color = '#f8f8f2'
intensity = 'Normal'
italic = true
strikethrough = false
underline = 'None'

[colors.tab_bar.new_tab]
bg_color = '#282a36'
fg_color = '#f8f8f2'
intensity = 'Normal'
italic = false
strikethrough = false
underline = 'None'

[colors.tab_bar.new_tab_hover]
bg_color = '#ff79c6'
fg_color = '#f8f8f2'
intensity = 'Normal'
italic = true
strikethrough = false
underline = 'None'

[metadata]
aliases = []
author = 'timescam'
name = 'Dracula (Official)'
origin_url = 'https://github.com/dracula/wezterm'

]]

return tabline
