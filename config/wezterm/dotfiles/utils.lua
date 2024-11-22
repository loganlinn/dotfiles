local wezterm = require("wezterm")

---@class dotfiles.utils
local M = {
  is = require("dotfiles.util.is"),
  safe = require("dotfiles.util.safe"),
  tbl = require("dotfiles.util.tbl"),
}

---@generic T
---@param ... nil|T
---@return T
function M.coalesce(...)
  local n = select("#", ...)
  for i = 1, n do
    local v = select(i, ...)
    if v ~= nil then
      return v
    end
  end
  return nil
end

---@class dotfiles.utils.str
local str = {}
M.str = str

---@param s string
---@param prefix string
---@return boolean
function str.startswith(s, prefix)
  return M.safe.isstring(s):sub(1, #prefix) == prefix
end

---@param s string
---@param suffix string
---@return boolean
function str.endswith(s, suffix)
  return suffix == "" or M.safe.isstring(s):sub(-#suffix) == suffix
end

function M.is_darwin()
  return str.endswith(wezterm.target_triple, "apple-darwin")
end

function M.is_linux()
  return str.endswith(wezterm.target_triple, "linux-gnu")
end

function M.is_windows()
  return str.endswith(wezterm.target_triple, "windows-msvc")
end

---@generic T
---@param t { linux?: T, darwin?: T, windows?: T}
---@return T
function M.match_platform(t)
  if M.is_linux() then
    return t.linux
  elseif M.is_darwin() then
    return t.darwin
  elseif M.is_windows() then
    return t.windows
  end
end

return M
