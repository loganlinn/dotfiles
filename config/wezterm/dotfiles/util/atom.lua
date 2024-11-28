local wezterm = require("wezterm")

---@class Atom
local M = {}

local MT = {
  __index = M,
  __newindex = function()
    error("atom: attempt to modify a read-only table", 2)
  end,
}

function M:deref()
  return wezterm.GLOBAL[self.key]
end

function M:reset(newval, ...)
  local oldval = self:deref()
  for key, fn in pairs(self.watches) do
    if fn then
      local ok, err = pcall(fn, key, self, oldval, newval, ...)
      if not ok then
        wezterm.log_error("atom", self.key, "watch", key, "error", err)
        return self
      end
    end
  end
  wezterm.GLOBAL[self.key] = newval
  return self
end

function M:swap(update, ...)
  return self:reset(update(self:deref(), ...), ...)
end

function M:add_watch(key, fn)
  assert(self.watches[key] == nil)
  self.watches[key] = fn
  return self
end

function M:remove_watch(key)
  self.watches[key] = nil
  return self
end

---@param key string|table
---@return Atom
function M:new(key)
  assert(key ~= nil)
  return setmetatable({
    key = key,
    watches = {},
  }, MT)
end

setmetatable(M, { __call = M.new })

return M
