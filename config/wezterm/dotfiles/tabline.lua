local wezterm = require("wezterm")
local warn = wezterm.log_warn
local util = require("dotfiles.util")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- wezterm.on("update-right-status", function(window, pane)
--   local cfg = window:effective_config()
--   local color = cfg.color_schemes[cfg.color_scheme]
--   -- wezterm.log_info(color)
--
--   window:set_right_status(wezterm.format(status))
-- end)

-- Custom tabline components
local components = {}
do
  local LEADER_IS_INACTIVE_TEXT = wezterm.format({
    { Foreground = { Color = "grey" } },
    { Text = " LEADER " },
  })
  local LEADER_IS_ACTIVE_TEXT = wezterm.format({
    { Foreground = { Color = "black" } },
    { Background = { Color = "green" } },
    { Text = " LEADER " },
  })
  function components.leader(window)
    if not window or not window.leader_is_active then
      warn("expected window argument, got", window)
      return
    end
    if window:leader_is_active() then
      return LEADER_IS_ACTIVE_TEXT
    else
      return LEADER_IS_INACTIVE_TEXT
    end
  end
end

function components.key_table(window)
  if not window or not window.effective_config then
    warn("expected window argument, got", window)
    return
  end
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
end

local config_reload_count = util.event_counter("window-config-reloaded")
function components.config_reload_count(window)
  return string.format(" v%d ", config_reload_count:deref())
end

tabline.setup({
  options = {
    icons_enabled = false,
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
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
      components.key_table,
      components.leader,
      components.config_reload_count,
      "ram",
    },
    tabline_y = {
      "datetime",
    },
    tabline_z = {
      "hostname",
    },
  },
  extensions = {},
})

return tabline
