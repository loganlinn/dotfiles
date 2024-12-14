local wezterm = require("wezterm")

local M = {}

-- Returns the number of nanoseconds from the epoch of 1970-01-01T00:00:00Z.
---@param time? wezterm.Time Specific time to use, defaults to current time.
---@return number
function M.nanos(time)
  return tonumber((time or wezterm.time.now()):format("%s%.f")) * 1e9
end

-- Returns the number of milliseconds from the epoch of 1970-01-01T00:00:00Z.
---@param time? wezterm.Time Specific time to use, defaults to current time.
---@return number
function M.millis(time)
  return tonumber((time or wezterm.time.now()):format("%s%.f")) * 1e3
end

---@class Stopwatch
---@field name string
local Stopwatch = {
  ---@return boolean
  running = function(self)
    return #self % 2 == 1
  end,

  ---@return Stopwatch
  start = function(self)
    assert(not self:running(), "illegal state: already started")
    self[#self + 1] = wezterm.time.now()
    return self
  end,

  ---@return Stopwatch
  stop = function(self)
    assert(self:running(), "illegal state: not started")
    self[#self + 1] = wezterm.time.now()
    return self
  end,

  ---@return Stopwatch
  reset = function(self)
    for i = 1, #self do
      self[i] = nil
    end
    return self
  end,

  millis = function(self)
    local t1, t2 = self:get()
    if t1 then
      return M.millis(t2) - M.millis(t1)
    end
  end,

  -- FIXME: i borked this
  get = function(self, i)
    local idx
    if i == nil then
      idx = #self // 2
    else
      idx = (i * 2) + 1
    end
    if idx > 0 then
      return self[idx], self[idx + 1]
    end
  end,

  tostring = function(self)
    return string.format("stopwatch: %s { running = %s, elapsed = %.3fms }", self.name, self.running(), self:millis())
  end,
}

---@param name? string
---@param autostart? boolean
---@return Stopwatch
function M.stopwatch(name, autostart)
  local self = {}
  self.name = name or string.format("%p", self)
  setmetatable(self, { __index = Stopwatch, __tostring = Stopwatch.tostring })
  if autostart == nil or autostart then
    self:start()
  end
  return self
end

return M
