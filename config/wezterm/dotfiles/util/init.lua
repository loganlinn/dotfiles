local wezterm = require("wezterm")
local is = require("dotfiles.util.is")
local safe = require("dotfiles.util.safe")
local tbl = require("dotfiles.util.tbl")

local M = {}
M.is = is
M.safe = safe
M.tbl = tbl

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

---@param t1 wezterm.Time
---@param t2 wezterm.Time
---@return number
function M.time_diff_ms(t1, t2)
  local t1_s = math.tointeger(t1:format("%s"))
  local t1_f = math.tointeger(t1:format("%f"))
  local t2_s = math.tointeger(t2:format("%s"))
  local t2_f = math.tointeger(t2:format("%f"))
  return (t1_s + (t1_f / 1000000)) - (t2_s + (t2_f / 1000000))
end

return M
