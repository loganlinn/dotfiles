local wezterm = require("wezterm")

local is = require("dotfiles.util.is")
local safe = require("dotfiles.util.safe")

local M = setmetatable({}, {
  __index = function(_, k)
    error("Key does not exist: " .. tostring(k))
  end,
})

M.is = is
M.safe = safe
M.tbl = require("dotfiles.util.tbl")
M.window = require("dotfiles.util.window")
M.delay = require("dotfiles.util.delay")

---@param f function
---@param ... any
---@return function
M.partial = function(f, ...)
  local bound = { ... }
  return function(...)
    return f(table.unpack(bound), ...)
  end
end

---@generic F : function
---@param f F
---@return F
M.fnil = function(f)
  return function(v, ...)
    if v ~= nil then
      return f(v, ...)
    end
  end
end

---@param number
---@return number
M.inc = function(n)
  return n + 1
end

---@param number
---@return number
M.dec = function(n)
  return n - 1
end

local spy_log = function(label, ...)
  wezterm.log_info("spy", label, ...)
  return ...
end

---@generic T
---@param ... T
---@return T
M.spy = function(...)
  return spy_log("VAL", ...)
end

M.fspy = function(f)
  return function(...)
    return spy_log("RET", f(spy_log("ARG", ...)))
  end
end

---@generic T
---@param v T|T[]
---@return T[]
M.tolist = function(v)
  if not is.table(v) or #v == 0 and next(v) ~= nil then
    return { v }
  end
  return v
end

---@generic T
---@param ... nil|T
---@return T
M.coalesce = function(...)
  local n = select("#", ...)
  for i = 1, n do
    local v = select(i, ...)
    if v ~= nil then
      return v
    end
  end
  return nil
end

---@param s string
---@param prefix string
---@return boolean
M.startswith = function(s, prefix)
  return string.sub(s, 1, #prefix) == prefix
end

---@param s string
---@param suffix string
---@return boolean
M.endswith = function(s, suffix)
  return suffix == "" or string.sub(s, -#suffix) == suffix
end

M.is_darwin = M.delay(function()
  return M.endswith(wezterm.target_triple, "apple-darwin")
end)

M.is_linux = M.delay(function()
  return M.endswith(wezterm.target_triple, "linux-gnu")
end)

M.is_windows = M.delay(function()
  return M.endswith(wezterm.target_triple, "windows-msvc")
end)

---@generic T
---@param t { linux?: T, darwin?: T, windows?: T, default?: T }
---@return T
function M.match_platform(t)
  if M.is_linux() then
    return t.linux
  elseif M.is_darwin() then
    return t.darwin
  elseif M.is_windows() then
    return t.windows
  end
  return t.default or error("no platform matched")
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

function M.event_counter(event)
  local counter = require("dotfiles.util.atom"):new("event.count\00" .. event)
  counter:swap(function(current)
    return current or 0
  end)
  local inc = wezterm.on(event, function(window, pane, ...)
    counter:swap(M.inc, window, pane)
  end)
  return counter
end

return M
