local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("open-uri.lua")

---@param pane Pane
---@return string|nil
local function pane_nvim_server(pane)
  local user_vars = pane:get_user_vars()
  if user_vars then
    return user_vars.NVIM or user_vars.NVIM_LISTEN_ADDRESS
  end
end

---@param tab MuxTab
---@return Pane[]
local function get_nvim_panes(tab)
  local panes_info = tab:panes_with_info()
  table.sort(panes_info, function(a, b)
    return (a.width * a.height) > (b.width * b.height)
  end)

  local results = {}
  for _, pane_info in ipairs(panes_info) do
    local pane = pane_info.pane
    if pane_nvim_server(pane) then
      table.insert(results, pane)
    end
  end
  return results
end

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

---@param server_address string
---@param file_path string
---@return boolean success
---@return string|nil stdout
---@return string|nil stderr
local function open_with_nvim_server(server_address, file_path)
  return wezterm.run_child_process(nvim_args("--server", server_address, "--remote-silent", file_path))
end

local function open_with_nvim(window, pane, url)
  if url.scheme ~= "file" then
    return false
  end
  -- open in new window when no nvim
  if (window:keyboard_modifiers() or "NONE") ~= "SUPER" then
    local panes_info = (pane and pane:tab() or window:active_tab()):panes_with_info()
    table.sort(panes_info, function(a, b)
      return (a.width * a.height) > (b.width * b.height)
    end)
    for _, pane_info in ipairs(panes_info) do
      local pane = pane_info.pane
      local nvim = pane_nvim_server(pane)
      log.info("opening", url, "with nvim server", nvim)
      if nvim and open_with_nvim_server(nvim, url.file_path) then
        pane:activate()
        return false
      end
    end
  end
  window:perform_action(
    wezterm.action.SpawnCommandInNewWindow({
      args = log.info(nvim_args("--", url.file_path)),
    }),
    pane
  )
  return false
end

return function(window, pane, uri)
  log.info("current event", window:current_event())
  local url = wezterm.url.parse(uri)
  log.info("parsed url", url)

  if url.scheme == "file" then
    if open_with_nvim(window, pane, url) then
      return false -- end propagation
    end
  end

  -- fallback
  wezterm.open_with(uri)
  return false
end
