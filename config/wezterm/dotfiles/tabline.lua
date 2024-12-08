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

-- Leader key status
function custom_components.leader()
  -- memoizes to avoid recomputing identical style strings
  local leader_active = util.delay(function()
    local scheme = tabline.get_colors().scheme
    return wezterm.format({
      { Background = { Color = scheme.ansi[7] } },
      { Foreground = { Color = scheme.ansi[1] } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " LEADER " },
      "ResetAttributes",
    })
  end)
  local leader_inactive = util.delay(function()
    local scheme = tabline.get_colors().scheme
    return wezterm.format({
      { Foreground = { Color = scheme.tab_bar.inactive_tab.fg_color } },
      { Text = " LEADER " },
      "ResetAttributes",
    })
  end)
  return window_component(function(window)
    if window:leader_is_active() then
      return leader_active()
    end
    return leader_inactive()
  end)
end

-- Key table status
function custom_components.key_table()
  return window_component(function(window)
    local active_key_table = window:active_key_table()
    if active_key_table then
      return wezterm.format({ Text = string.format(" %s ", active_key_table) })
      -- table.insert(status, { Foreground = { AnsiColor = "Fuchsia" } })
      -- table.insert(status, { Attribute = { Intensity = "Bold" } })
      -- table.insert(status, { Text = string.format(" %s ", active_key_table) })
      -- table.insert(status, { Attribute = { Intensity = "Normal" } })
      -- table.insert(status, {
      --   Text = string.format(
      --     "[%s]",
      --     table.concat(
      --       util.tbl.map(function(_, v)
      --         return v.key
      --       end,
      --       window:effective_config().key_tables[active_key_table]),
      --       "|"
      --     )
      --   ),
      -- })
      -- table.insert(status, "ResetAttributes")
      -- table.insert(status, { Text = " " })
    end
    return ""
  end)
end

function custom_components.config_reload_count()
  local state = util.event_counter("window-config-reloaded")
  return function(_)
    return string.format(" v%d ", state:deref())
  end
end

tabline.setup({
  extensions = {},
  options = {
    icons_enabled = false,
    section_separators = {
      left = nerdfonts.pl_left_hard_divider,
      right = nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = nerdfonts.pl_left_soft_divider,
      right = nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = nerdfonts.pl_left_hard_divider,
      right = nerdfonts.pl_right_hard_divider,
    },
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
      custom_components.leader(),
      -- custom_components.config_reload_count(),
    },
    tabline_y = {
      "ram",
    },
    tabline_z = {
      "datetime",
      -- "hostname",
    },
  },
})

return tabline
