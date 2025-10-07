local wezterm = require("wezterm")
local nerdfonts = wezterm.nerdfonts
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local foreground_process_name = ""

local util = require("dotfiles.util")
local basename = util.basename
local dirname = util.dirname
local str = wezterm.to_string
local lpad, rpad = wezterm.pad_left, wezterm.pad_right
local ltrunc, rtrunc = wezterm.truncate_left, wezterm.truncate_right
local lmargin = function(s, n)
  n = n or 1
  while n > 0 do
    s = " " .. s
    n = n - 1
  end
  return s
end
local rmargin = function(s, n)
  n = n or 1
  while n > 0 do
    s = s .. " "
    n = n - 1
  end
  return s
end
local margin = function(s, n1, n2)
  return lmargin(rmargin(s, n1), n2 or n1)
end

-- https://wezfurlong.org/wezterm/config/lua/color/index.html#available-methods
local C = {}
C.Background = wezterm.color.parse("#282A36")
C.Foreground = wezterm.color.parse("#F8F8F2")
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
      { Text = margin(key_table .. " " .. nerdfonts.cod_layers_dot) },
      "ResetAttributes",
    })
  else
    return wezterm.format({
      { Foreground = { Color = inactive_fg_color } },
      { Text = " " .. nerdfonts.cod_layers .. "  " },
      "ResetAttributes",
    })
  end
end

local function leader_key()
  local leader_text = margin(nerdfonts.md_home_floor_l, 1)
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

-- local process_to_icon = {
--   -- ["air"] = { nerdfonts.md_language_go, color = { fg = colors.brights[5] } },
--   -- ["apt"] = { nerdfonts.dev_debian, color = { fg = colors.ansi[2] } },
--   -- ["bacon"] = { nerdfonts.dev_rust, color = { fg = colors.ansi[2] } },
--   ["bash"] = { nerdfonts.cod_terminal_bash, color = { fg = colors.cursor_bg or nil } },
--   ["bat"] = { nerdfonts.md_bat, color = { fg = colors.ansi[5] } },
--   ["btm"] = { nerdfonts.md_chart_donut_variant, color = { fg = colors.ansi[2] } },
--   ["btop"] = { nerdfonts.md_chart_areaspline, color = { fg = colors.ansi[2] } },
--   -- ["btop4win++"] = { nerdfonts.md_chart_areaspline, color = { fg = colors.ansi[2] } },
--   ["bun"] = { nerdfonts.md_hamburger, color = { fg = colors.cursor_bg or nil } },
--   ["cargo"] = { nerdfonts.dev_rust, color = { fg = colors.ansi[2] } },
--   ["chezmoi"] = { nerdfonts.md_home_plus_outline, color = { fg = colors.brights[5] } },
--   ["cmd.exe"] = { nerdfonts.md_console_line, color = { fg = colors.cursor_bg or nil } },
--   ["curl"] = nerdfonts.md_flattr,
--   ["debug"] = { nerdfonts.cod_debug, color = { fg = colors.ansi[5] } },
--   ["default"] = nerdfonts.md_application,
--   ["docker"] = { nerdfonts.md_docker, color = { fg = colors.ansi[5] } },
--   ["docker-compose"] = { nerdfonts.md_docker, color = { fg = colors.ansi[5] } },
--   ["dpkg"] = { nerdfonts.dev_debian, color = { fg = colors.ansi[2] } },
--   ["fish"] = { nerdfonts.md_fish, color = { fg = colors.cursor_bg or nil } },
--   ["gh"] = { nerdfonts.dev_github_badge, color = { fg = colors.brights[4] or nil } },
--   ["git"] = { nerdfonts.dev_git, color = { fg = colors.brights[4] or nil } },
--   ["go"] = { nerdfonts.md_language_go, color = { fg = colors.brights[5] } },
--   ["htop"] = { nerdfonts.md_chart_areaspline, color = { fg = colors.ansi[2] } },
--   ["kubectl"] = { nerdfonts.md_docker, color = { fg = colors.ansi[5] } },
--   ["kuberlr"] = { nerdfonts.md_docker, color = { fg = colors.ansi[5] } },
--   ["lazydocker"] = { nerdfonts.md_docker, color = { fg = colors.ansi[5] } },
--   ["lazygit"] = { nerdfonts.cod_github, color = { fg = colors.brights[4] or nil } },
--   ["lua"] = { nerdfonts.seti_lua, color = { fg = colors.ansi[5] } },
--   ["make"] = nerdfonts.seti_makefile,
--   ["nix"] = { nerdfonts.linux_nixos, color = { fg = colors.ansi[5] } },
--   ["node"] = { nerdfonts.md_nodejs, color = { fg = colors.brights[2] } },
--   ["npm"] = { nerdfonts.md_npm, color = { fg = colors.brights[2] } },
--   ["nvim"] = { nerdfonts.custom_neovim, color = { fg = colors.ansi[3] } },
--   ["pacman"] = { nerdfonts.md_pac_man, color = { fg = colors.ansi[4] } },
--   ["paru"] = { nerdfonts.md_pac_man, color = { fg = colors.ansi[4] } },
--   ["pnpm"] = { nerdfonts.md_npm, color = { fg = colors.brights[4] } },
--   ["postgresql"] = { nerdfonts.dev_postgresql, color = { fg = colors.ansi[5] } },
--   ["powershell.exe"] = { nerdfonts.md_console, color = { fg = colors.cursor_bg or nil } },
--   ["psql"] = { nerdfonts.dev_postgresql, color = { fg = colors.ansi[5] } },
--   ["pwsh.exe"] = { nerdfonts.md_console, color = { fg = colors.cursor_bg or nil } },
--   ["rpm"] = { nerdfonts.dev_redhat, color = { fg = colors.ansi[2] } },
--   ["redis"] = { nerdfonts.dev_redis, color = { fg = colors.ansi[5] } },
--   ["ruby"] = { nerdfonts.cod_ruby, color = { fg = colors.brights[2] } },
--   ["rust"] = { nerdfonts.dev_rust, color = { fg = colors.ansi[2] } },
--   ["serial"] = nerdfonts.md_serial_port,
--   ["ssh"] = nerdfonts.md_ssh,
--   ["sudo"] = nerdfonts.fa_hashtag,
--   ["tls"] = nerdfonts.md_power_socket,
--   ["topgrade"] = { nerdfonts.md_rocket_launch, color = { fg = colors.ansi[5] } },
--   ["unix"] = nerdfonts.md_bash,
--   ["valkey"] = { nerdfonts.dev_redis, color = { fg = colors.brights[5] } },
--   ["vim"] = { nerdfonts.dev_vim, color = { fg = colors.ansi[3] } },
--   ["wget"] = nerdfonts.md_arrow_down_box,
--   ["yarn"] = { nerdfonts.seti_yarn, color = { fg = colors.ansi[5] } },
--   ["yay"] = { nerdfonts.md_pac_man, color = { fg = colors.ansi[4] } },
--   ["yazi"] = { nerdfonts.md_duck, color = { fg = colors.brights[4] or nil } },
--   ["yum"] = { nerdfonts.dev_redhat, color = { fg = colors.ansi[2] } },
--   ["zsh"] = { nerdfonts.dev_terminal, color = { fg = colors.cursor_bg or nil } },
-- }

-- special behavior for certain processes
---@type table<string, string | fun(tab): string>
local tab_label_by_foreground_process_name = {
  psql = function(tab_info)
    return wezterm.format({
      { Foreground = { Color = C.Comment } },
      { Text = nerdfonts.dev_postgresql .. "  " },
      { Foreground = { Color = C.Foreground } },
      { Text = "psql" },
    })
  end,
  duckdb = function(tab_info)
    return wezterm.format({
      { Foreground = { Color = C.Comment } },
      { Text = nerdfonts.md_duck .. "  " },
      { Foreground = { Color = C.Foreground } },
      { Text = "duckdb" },
    })
  end,
  ssh = "ssh",
  clickhouse = "clickhouse",
}

local tab_label = function(tab, opts)
  opts = opts or {}

  -- get the foreground process name if available
  if tab.active_pane and tab.active_pane.foreground_process_name then
    foreground_process_name = tab.active_pane.foreground_process_name
    foreground_process_name = basename(foreground_process_name) or foreground_process_name
  end

  -- fallback to the title if the foreground process name is unavailable
  -- Wezterm uses OSC 1/2 escape sequences to guess the process name and set the title
  -- see https://wezfurlong.org/wezterm/config/lua/pane/get_title.html
  -- title defaults to 'wezterm' if another name is unavailable
  -- Also, when running under WSL, try to use the OSC 1/2 escape sequences as well
  if foreground_process_name == "" or foreground_process_name == "wslhost.exe" then
    foreground_process_name = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
  end

  -- if the tab active pane contains a non-local domain, use the domain name
  if foreground_process_name == "wezterm" then
    foreground_process_name = tab.active_pane.domain_name ~= "local" and tab.active_pane.domain_name or "wezterm"
  end

  local title = tab.tab_title
  if title == "" or title == "default" then
    local process_title = tab_label_by_foreground_process_name[foreground_process_name]
    if type(process_title) == "string" then
      title = process_title
    elseif type(process_title) == "boolean" then
      if process_title then
        title = foreground_process_name
      end
    elseif process_title then
      title = process_title(tab)
    end
  end

  if title ~= "" and title ~= "default" then
    return wezterm.format({
      { Foreground = { Color = C.Pink } },
      { Text = margin(title, 1) },
      "ResetAttributes",
    })
  end

  local insert = table.insert
  local fmt = {}
  if tab.active_pane.current_working_dir then
    local cwd = tab.active_pane.current_working_dir.file_path
    local label = basename(cwd)

    if #(wezterm.mux.get_window(tab.window_id):tabs()) < 10 then
      local parent = basename(dirname(cwd))
      if parent and parent ~= "." and parent ~= "/" then
        insert(fmt, { Foreground = { Color = "#909090" } })
        insert(fmt, { Text = parent })
        insert(fmt, { Foreground = { AnsiColor = "Grey" } })
        insert(fmt, { Text = "/" })
        insert(fmt, "ResetAttributes")
      end
    end
    insert(fmt, { Foreground = { AnsiColor = "White" } })
    insert(fmt, { Text = label })
  elseif tab.active_pane.foreground_process_name then
    insert(fmt, { Text = basename(tab.active_pane.foreground_process_name) })
  end
  insert(fmt, "ResetAttributes")
  return wezterm.format(fmt)
end

local function tab_section(is_active)
  return {
    { Attribute = { Intensity = is_active and "Bold" or "Half" } },
    { "index", padding = { left = 2, right = 1 } },
    tab_label,
    " ",
    {
      "zoomed",
      icons_enabled = true,
      icons_only = true,
      padding = 0,
    },
    " ",
  }
end

local options = {
  icons_enabled = false,
  -- section_separators = { left = nerdfonts.pl_left_hard_divider, right = nerdfonts.pl_right_hard_divider },
  -- component_separators = { left = "", right = "" },
  -- tab_separators = { left = "", right = "" },
  padding = 1,
  theme = "Dracula (Official)",
  theme_overrides = {
    normal_mode = {
      -- different color workspace name (prob a better place to set this)
      -- b = { bg = C.Background:darken(0.2), fg = C.Foreground },
      b = { bg = C.CurrentLine, fg = C.Foreground },
    },
    copy_mode = {},
    search_mode = {},
    window_mode = {},
    tab = {
      active = {},
      inactive = {},
      inactive_hover = {},
    },
  },
}

local function pane_title(window)
  local tabs = window:mux_window():tabs()
  if #tabs > 5 then
    return ""
  end

  local tab = window and window:active_tab()
  local pane = tab and tab:active_pane()
  local title = pane and pane:get_title() or ""
  if #title > 42 then
    title = rtrunc(title, 39) .. "..."
  end
  return margin(title, 1)
end

tabline.setup({
  options = options,
  sections = {
    tabline_a = {
      { "mode", padding = 2 },
    },
    tabline_b = {
      { "workspace", padding = 2 },
    },
    tabline_c = {
      -- "    ",
    },
    tab_active = tab_section(true),
    tab_inactive = tab_section(false),
    tabline_x = {
      -- config_reload_count(),
      -- active_key_table,
      -- leader_key(),
    },
    tabline_y = {
      pane_title,

      -- function(window)
      --   return string.format(
      --     " %s, %s, %s ",
      --     window:window_id(),
      --     window:active_tab():tab_id(),
      --     window:active_pane():pane_id()
      --   )
      -- end,

      -- {
      --   "window",
      --   padding = 2,
      --   cond = function(window)
      --     return window:mux_window():get_title() == "default"
      --   end,
      -- },
      -- {
      --   "domain",
      --   icons_enabled = false,
      --   padding = 2,
      --   domain_to_icon = {
      --     default = nerdfonts.md_monitor,
      --     ssh = nerdfonts.md_ssh,
      --     wsl = nerdfonts.md_microsoft_windows,
      --     docker = nerdfonts.md_docker,
      --     unix = nerdfonts.cod_terminal_linux,
      --   },
      -- },
    },
    tabline_z = {
      {
        "datetime",
        style = "%F %I:%M%P", -- 2025-08-20 01:23pm
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
