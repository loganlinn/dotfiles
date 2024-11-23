local wezterm = require("wezterm")
local util = require("dotfiles.util")
local is, safe = util.is, util.safe

local M = {}

---@class Mods
local Mods = {}

Mods.labels = setmetatable({
  CTRL = "CTRL",
  SHIFT = "SHIFT",
  ALT = "ALT",
  SUPER = "SUPER",
}, {
  __index = {
    META = "ALT",
    OPT = "ALT",
    CMD = "SUPER",
    WIN = "SUPER",
  },
  __newindex = function()
    error("attempt to modify a read-only table", 2)
  end,
})

local function mods_init_1(self, arg)
  if is.table(arg) then
    if arg[1] ~= nil then
      for _, v in ipairs(arg) do
        mods_init_1(self, tostring(v))
      end
    else
      for k, v in pairs(arg) do
        if v then
          mods_init_1(self, tostring(k))
        end
      end
    end
  else
    for mod in tostring(arg):gmatch("[^|]+") do
      if rawget(self, mod) == nil then
        rawset(self, mod, true)
      end
    end
  end
end

---@param ... string|string[]
---@return Mods
function Mods:init(...)
  for i = 1, select("#", ...) do
    mods_init_1(self, select(i, ...))
  end
  return self
end

---@param ... string|string[]
---@return Mods
function Mods:new(...)
  return setmetatable(self, {
    __index = self,
    __tostring = function(self_)
      return table.concat(self_, "|")
    end,
    __newindex = function()
      error("attempt to modify a read-only table", 2)
    end,
    __add = function(self, other)
      return Mods:new(self, other)
    end,
    __eq = function(self, other)
      if #self ~= #other then
        return false
      end
    end,
  }):init(...)
end

-- local ModEnum = setmetatable({
--   CTRL = Mods:new("CTRL"),
--   SHIFT = Mods:new("SHIFT"),
--   ALT = Mods:new("ALT"),
--   SUPER = Mods:new("SUPER"),
--   VOID = Mods:new("VoidSymbol"),
-- }, {
--   __index = function(self, key)
--     local alias = ModAlias[tostring(key)]
--     if alias ~= nil then
--       return rawget(self, alias)
--     end
--     error("invalid key: " .. tostring(key))
--   end,
--   __newindex = function()
--     error("attempt to modify a read-only table", 2)
--   end,
-- })

Mods = setmetatable(Mods, {
  __index = function(_, key)
    return ModEnum[key]
  end,
  __call = Mods.new,
  __newindex = function()
    error("attempt to modify a read-only table", 2)
  end,
})

M.Mods = Mods

function M:key(mods, key, action)
  key = safe.isstring(key)
  if not is.string(mods) then
    mods = table.concat(safe.istable(mods), "|")
  end
  if is.fn(action) then
    action = wezterm.action_callback(action)
  end
  local key_assignment = {
    key = key,
    mods = mods,
    action = action,
  }
end

function M:apply_to_config(config) end

return M
