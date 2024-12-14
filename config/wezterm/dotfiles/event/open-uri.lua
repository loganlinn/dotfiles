local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("open-uri.lua")

local function discover_nvim_servers(window)
  local results = {}
  for _, pane in ipairs(window:active_tab():panes()) do
    local user_vars = pane:get_user_vars()
    if user_vars and user_vars.NVIM_LISTEN_ADDRESS then
      table.insert(results, user_vars.NVIM_LISTEN_ADDRESS)
    end
  end
  return log.info(results)
end

local function open_with_nvim(window, pane, file_path)
  for _, nvim_server in ipairs(discover_nvim_servers(window)) do
    if
      log.info(wezterm.run_child_process(log.info({
        "/usr/bin/env",
        "zsh",
        "-c",
        [[nvim --server "$1" --remote-silent "$2"]],
        "-s",
        nvim_server,
        file_path,
      })))
    then
      return true
    end
  end
end

return function(window, pane, uri)
  local url = wezterm.url.parse(uri)
  wezterm.log_info("parsed url", url)
  if url.scheme == "file" then
    if open_with_nvim(window, pane, url.file_path) then
      return false
    end
  end
  wezterm.open_with(uri)
end
