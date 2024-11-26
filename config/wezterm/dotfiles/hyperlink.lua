local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  assert(not config.hyperlink_rules, "Avoiding overwriting hyperlink_rules")
  config.hyperlink_rules = wezterm.default_hyperlink_rules()

  local def_hyperlink_rules = function(...)
    for i = 1, select("#", ...) do
      local arg = select(i, ...)
      local rule = {
        regex = arg.regex or arg[1],
        format = arg.format or arg[2],
        highlight = arg.highlight or arg[3] or 0,
      }
      -- wezterm.log_info("hyperlink rule", rule)
      table.insert(config.hyperlink_rules, rule)
    end
  end

  def_hyperlink_rules(
    -- linear task
    { [[\b(G-\d+)\b]], "https://linear.app/gamma-app/issue/$1" },
    -- git repo
    { [[["']?(github:|gitlab:)?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["']?]], "https://www.github.com/$2/$4" }
    -- TODO: support more of nix flakerefs <https://github.com/NixOS/nix/blob/master/src/nix/flake.md>
  )

  return config, def_hyperlink_rules
end

return M
