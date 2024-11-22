local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- wezterm.on("update-right-status", function(window, pane)
--   local cfg = window:effective_config()
--   local color = cfg.color_schemes[cfg.color_scheme]
--   -- wezterm.log_info(color)
--
--   local status = {}
--
--   local active_key_table = window:active_key_table()
--   if active_key_table then
--     table.insert(status, { Foreground = { AnsiColor = "Fuchsia" } })
--     table.insert(status, { Attribute = { Intensity = "Bold" } })
--     table.insert(status, { Text = string.format(" %s ", active_key_table) })
--     table.insert(status, { Attribute = { Intensity = "Normal" } })
--     table.insert(status, {
--       Text = string.format(
--         "[%s]",
--         table.concat(
--           utils.tbl.map(function(_, v)
--             return v.key
--           end, cfg.key_tables[active_key_table]),
--           "|"
--         )
--       ),
--     })
--     table.insert(status, "ResetAttributes")
--     table.insert(status, { Text = " " })
--   end
--
--   if window:leader_is_active() then
--     table.insert(status, { Foreground = { Color = "black" } })
--     table.insert(status, { Background = { Color = "green" } })
--   else
--     table.insert(status, { Foreground = { Color = "grey" } })
--   end
--   table.insert(status, { Text = " LEADER " })
--   table.insert(status, "ResetAttributes")
--   table.insert(status, { Text = " " })
--
--   for i, workspace_name in pairs(wezterm.mux.get_workspace_names()) do
--     if workspace_name == window:active_workspace() then
--       table.insert(status, { Background = { Color = color.brights[1] } })
--     end
--     table.insert(status, { Text = string.format(" %d: %s ", i, workspace_name) })
--     table.insert(status, "ResetAttributes")
--   end
--   window:set_right_status(wezterm.format(status))
-- end)

tabline.setup({
  options = {
    icons_enabled = false,
    -- section_separators = '',
    -- component_separators = '',
    -- tab_separators = '',
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
        b = { bg = "#6272A4", fg = "#F8F8F2" },
      },
    },
  },
  sections = {
    tabline_a = { "mode" },
    tabline_b = {
      { Attribute = { Intensity = "Bold" } },
      "workspace",
    },
    tabline_c = { " " },
    tab_active = {
      "index",
      { "parent", padding = 0 },
      "/",
      { "cwd", padding = { left = 0, right = 1 } },
      { "zoomed", padding = 0 },
    },
    tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
    tabline_x = { "ram", "cpu" },
    tabline_y = { "datetime" },
    tabline_z = { "hostname" },
  },
  extensions = {},
})

return tabline
