local wezterm = require("wezterm")
local is = require("dotfiles.util.is")
local safe = require("dotfiles.util.safe")
local tbl = require("dotfiles.util.tbl")

local M = {}
M.is = is
M.safe = safe
M.tbl = tbl

M.inc = function(n)
  return n + 1
end

M.dec = function(n)
  return n - 1
end

---@generic T
---@param ... T
---@return T
M.spy = function(...)
  wezterm.log_info("spy:", ...)
  return ...
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
  return t.default
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

--------------------------------------------------------------------------------

do
  local prototype = {
    deref = function(self)
      if self.__fn then
        local ok, val = pcall(self.__fn)
        if ok then
          self.__val = val
        else
          self.__err = val
        end
        self.__fn = nil
      end
      if self.__err then
        error(self.__err, 2)
      end
      return self.__val
    end,
    realized = function(self)
      return self.__fn == nil
    end,
  }

  local metatable = {
    __index = prototype,
    __call = prototype.deref,
  }

  M.delay = function(fn)
    return setmetatable({ __fn = fn, __val = nil, __err = nil }, metatable)
  end
end

--------------------------------------------------------------------------------

local atom = {}
atom.prototype = {}
atom.metatable = {
  __index = atom.prototype,
  __newindex = function()
    error("atom: attempt to modify a read-only table", 2)
  end,
}

function atom.prototype:deref()
  return wezterm.GLOBAL[self.name]
end

function atom.prototype:reset(newval, ...)
  local oldval = self:deref()
  for key, fn in pairs(self.watches) do
    if fn then
      local ok, err = pcall(fn, key, self, oldval, newval, ...)
      if not ok then
        wezterm.log_error("atom", self.name, "watch", key, "error", err)
        return self
      end
    end
  end
  wezterm.GLOBAL[self.name] = newval
  return self
end

function atom.prototype:swap(update, ...)
  return self:reset(update(self:deref(), ...), ...)
end

function atom.prototype:add_watch(key, fn)
  assert(self.watches[key] == nil)
  self.watches[key] = fn
  return self
end

function atom.prototype:remove_watch(key)
  self.watches[key] = nil
  return self
end

function atom:new(id)
  assert(id ~= nil)
  return setmetatable({
    name = id,
    watches = {},
  }, atom.metatable)
end

setmetatable(atom, { __call = atom.new })

M.atom = atom

function M.event_counter(event)
  local counter = atom:new("event.count\00" .. event)
  counter:swap(function(current)
    return current or 0
  end)
  local inc = wezterm.on(event, function(window, pane, ...)
    counter:swap(M.inc, window, pane)
  end)
  return counter
end

return M
