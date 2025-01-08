local wezterm = require("wezterm")
local util = require("dotfiles.util")
local log = require("dotfiles.util.logger").new("open-uri.lua")

---@param ... string
---@return string[]
local function nvim_args(...)
  local nvim_exe = require("dotfiles.util.exepath")("nvim")
  if nvim_exe then
    return { nvim_exe, ... }
  else
    return { "/usr/bin/env", "zsh", "-c", [[exec nvim]], "-s", ... }
  end
end

---@param window Window
---@param pane Pane
---@param url Url
---@return boolean success
local function open_with_nvim_remote(window, pane, url)
  -- skip quick open when super held
  if string.find(window:keyboard_modifiers() or "NONE", "SUPER") then
    return false
  end

  local panes_info = (pane and pane:tab() or window:active_tab()):panes_with_info()
  table.sort(panes_info, function(a, b)
    return (a.width * a.height) > (b.width * b.height)
  end)
  for _, pane_info in ipairs(panes_info) do
    local pane = pane_info.pane
    local user_vars = pane:get_user_vars()
    local server = user_vars and user_vars.NVIM or user_vars.NVIM_LISTEN_ADDRESS
    if server then
      log.info("pane has nvim server user var", server)
      if not util.is_readable(server) then
        log.info("ignoring", server, "from pane", pane)
      else
        local args = nvim_args("--server", server, "--remote", url.file_path)
        log.info("running child process", args)
        local success, stdout, stderr = wezterm.run_child_process(args)
        log.info(success, stdout, stderr)
        if success then
          pane:activate()
          return true
        end
      end
    end
  end
  return false
end

local function open_with_nvim_tab(window, pane, url)
  return true
end

---@param window Window
---@param pane Pane
---@param uri string
---@return boolean success
local function open_with_nvim(window, pane, uri)
  local url = wezterm.url.parse(uri)

  if url.scheme ~= "file" then
    return false
  end

  if not open_with_nvim_remote(window, pane, url) then
    local args = nvim_args("--", url.file_path)
    log.info("spawning command", args)
    log.info(window:perform_action(wezterm.action.SpawnCommandInNewTab({ args = args }), pane))
  end

  return true
end

return function(window, pane, uri)
  if open_with_nvim(window, pane, uri) then
    return false -- cancel propagation
  end
end
