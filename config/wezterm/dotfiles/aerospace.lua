local wezterm = require("wezterm")

local util = require("dotfiles.util")

local aerospace = {}

aerospace.get_executable_path = function()
  local path = require("dotfiles.util.exepath")("aerospace")
  aerospace.get_executable_path = function()
    return path
  end
  return path
end

function aerospace.apply_to_config(config)
  -- if util.is_darwin() then
  --   local aerospace_bin = aerospace.get_executable_path()
  --   wezterm.log_warn("aerospace executable path", aerospace_bin)
  --   if aerospace_bin then
  --     wezterm.on("activate-direction", function(window, pane, direction)
  --       wezterm.log_info("aerospace: activate-direction", direction)
  --       wezterm.run_child_process({
  --         aerospace_bin,
  --         "focus",
  --         "--boundaries",
  --         "all-monitors-outer-frame",
  --         "--boundaries-action",
  --         "wrap-around-the-workspace",
  --         direction:lower(),
  --       })
  --     end)
  --   end
  -- end
  return config
end

return aerospace
