--- https://github.com/wez/wezterm/blob/4050072da21cc3106d0985281d75978c07e22abc/config/src/keys.rs#L115
---@alias KeyCode string
---
---@class KeyNoAction
---@field key KeyCode
---@field mods? KeyCode
---
---@class Key: KeyNoAction
---@field action KeyAssignment
---
---@class Keybinds: Key[]
---@field prefix {[1]: string}|KeyNoAction

local wezterm = require("wezterm")
local log = wezterm.log_info
local is = require("dotfiles.util.is")

local M = {}

local private = {
  keys = {},
  key_tables = {},
  prefix_keys = {},
}

function M.has_key_table(name)
  assert(is.string(name) and name ~= "", "invalid key table name")
  local key_table = private.key_tables[name]
  return key_table ~= nil, key_table
end

function M.init_key_table(name, keys)
  assert(not M.has_key_table(name), "key table already exists")
  keys = keys or {}
  private.key_tables[name] = keys
  return keys
end

---@param name? string
---@return Key[]
function M.get_key_table(name)
  if name then
    return private.key_tables[name]
  end
end

function Keymap.prototype:bind(opts)
  assert(is.table(opts))

  -- The table we will insert keys into
  ---@type Key[]
  local key_table

  if is.some(opts.prefix) then
    if is.string(opts.prefix) then
      -- key table by name, no activation key
      key_table = M.get_key_table(opts.prefix) or M.init_key_table(opts.prefix)
    else
      assert(is.table(opts.prefix))
      assert(is.string(opts.prefix[1]), "first element of prefix must be a string name of a key table")
      key_table = M.get_key_table(opts.prefix[1]) or M.init_key_table(opts.prefix[1])
      local activate_key = {
        key = opts.prefix.key,
        mods = opts.prefix.mods,
        action = wezterm.action.ActivateKeyTable({ name = opts.prefix[1] }),
      }
      self:bind({ activate_key })
    end
  else
    log("Inserting into main key table")
    key_table = self.keys
  end

  for _, key in ipairs(opts) do
    assert(is.table(key))
    assert(is.string(key.key))
    assert(key.mods == nil or is.string(key.mods))
    assert(is.some(key.action))
    table.insert(key_table, key)
  end
  if not opts.disable_default_key_bindings then
    if opts.prefix ~= nil then
      table.insert(key_table, { key = "Escape", action = wezterm.action.ClearKeyTableStack })
      table.insert(key_table, { key = "g", mods = "CTRL", action = wezterm.action.ClearKeyTableStack })
      table.insert(key_table, { key = "c", mods = "CTRL", action = wezterm.action.ClearKeyTableStack })
    end
  end
  return self
end

function Keymap.prototype:apply_to_config(config)
  -- TOOD use extend_keys
  config.keys = config.keys or {}
  for _, key in ipairs(self.keys) do
    table.insert(config.keys, key)
  end
  for name, keys in pairs(self.key_tables) do
    config.key_tables = config.key_tables or {}
    local key_table = config.key_tables[name] or {}
    for _, key in ipairs(keys) do
      table.insert(key_table, key)
    end
    config.key_tables[name] = key_table
  end
  return config
end

return Keymap

--[[ SCRATCH

local Mods = {}
Mods.keycodes = setmetatable({
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
local ModEnum = setmetatable({
  CTRL = Mods:new("CTRL"),
  SHIFT = Mods:new("SHIFT"),
  ALT = Mods:new("ALT"),
  SUPER = Mods:new("SUPER"),
  VOID = Mods:new("VoidSymbol"),
}, {
  __index = function(self, key)
    local alias = ModAlias[tostring(key)]
    if alias ~= nil then
      return rawget(self, alias)
    end
    error("invalid key: " .. tostring(key))
  end,
  __newindex = function()
    error("attempt to modify a read-only table", 2)
  end,
})

]]
