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

  wezterm.on("open-uri", function(window, pane, uri)
    wezterm.log_info("open-uri", uri)
    -- local start, match_end = uri:find 'mailto:'
    -- if start == 1 then
    --   local recipient = uri:sub(match_end + 1)
    --   window:perform_action(
    --   wezterm.action.SpawnCommandInNewWindow {
    --     args = { 'mutt', recipient },
    --   },
    --   pane
    --   )
    --   -- prevent the default action from opening in a browser
    --   return false
    -- end
    -- otherwise, by not specifying a return value, we allow later
    -- handlers and ultimately the default action to caused the
    -- URI to be opened in the browser
  end)

  return config, def_hyperlink_rules
end

return M
