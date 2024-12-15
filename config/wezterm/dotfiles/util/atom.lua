local wezterm = require("wezterm")

---@alias atom.key string|table
---@alias atom.watch fun(key: atom.key, self: atom, oldval: any, newval: any)
---@class atom
---@field watches table<atom.key, atom.watch>
local atom = {}

function atom:deref()
  return wezterm.GLOBAL[self.key]
end

function atom:reset(newval)
  local oldval = self:deref()
  for key, fn in pairs(self.watches) do
    if fn then
      local ok, err = pcall(fn, key, self, oldval, newval)
      if not ok then
        wezterm.log_error("atom", self.key, "watch", key, "error", err)
        return self
      end
    end
  end
  wezterm.GLOBAL[self.key] = newval
  return self
end

function atom:swap(update, ...)
  return self:reset(update(self:deref(), ...), ...)
end

function atom:add_watch(key, fn)
  assert(self.watches[key] == nil)
  self.watches[key] = fn
  return self
end

function atom:remove_watch(key)
  self.watches[key] = nil
  return self
end

---@param key atom.key
---@return atom
function atom:new(key)
  return setmetatable({
    key = assert(key),
    watches = {},
  }, {
    __index = self,
  })
end

setmetatable(atom, { __call = atom.new, __newindex = error })

return atom
