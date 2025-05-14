local wezterm = require("wezterm")
local mux = wezterm.mux
local log = require("dotfiles.util.logger").new("dotfiles.event.gui-attached")

---@return MuxWindow[]
local find_workspace_windows = function(workspace)
  local windows = {}
  for _, window in ipairs(mux.all_windows()) do
    if window:get_workspace() == workspace then
      table.insert(windows, window)
    end
  end
  return windows
end

wezterm.on("gui-attached", function(domain)
  local active_workspace = mux.get_active_workspace()
  log.info("domain:", domain, "active_workspace:", active_workspace)

  if domain == "TermWizTerminalDomain" then
    local windows = find_workspace_windows(active_workspace)
    log.info("active workspace", active_workspace)
    log.info("windows", { windows })
  end
end)
