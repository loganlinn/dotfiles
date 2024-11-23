local act = require("dotfiles.action")
local is = require("dotfiles.util.is")

local function insert_clear_key_table_stack_keys(key_table)
  table.insert(key_table, { key = "Escape", action = act.ClearKeyTableStack })
  table.insert(key_table, { key = "g", mods = "CTRL", action = act.ClearKeyTableStack })
  table.insert(key_table, { key = "c", mods = "CTRL", action = act.ClearKeyTableStack })
  return key_table
end

local function keystr(key)
  -- TODO normalize mods
  return string.format("%s-%s", key.mods, key.key)
end

-- local function index_keys(keys)
--   local index = {}
--   for _, key in ipairs(keys) do
--     table.insert(index, key_token(key))
--   end
--   return index
-- end
--
-- local function merge_keys_with(fn, base, other)
--   assert(is.callable(fn))
--   local index = index_keys(base)
--   for _, key in ipairs(other) do
--     local token = key_token(key)
--     local existing = index[token]
--     if existing ~= nil then
--       if fn(existing, key) ~= true then
--         return base
--       end
--     end
--   end
--   for _, key in ipairs(other) do
--     table.insert(base, key)
--   end
--   return base
-- end
--
local Keymap = {}
Keymap.prototype = {}
Keymap.metatable = { __index = Keymap.prototype }

function Keymap:create()
  local obj = setmetatable({}, Keymap.metatable)
  obj:init()
  return obj
end

setmetatable(Keymap, { __call = Keymap.create })

function Keymap.prototype:init()
  self.keys = {}
  self.key_tables = {}
end

function Keymap.prototype:key_table(name)
  if name == nil then
    return self.keys
  end
  assert(is.string(name))
  local key_table = self.key_tables[name]
  if key_table == nil then
    key_table = {}
    self.key_tables[name] = key_table
  end
  return key_table
end

---@class Keymap.KeyInput
---@field key string
---@field mods string

---@class Keymap.Keymap
---@field name? string
---@field keys KeyBinding[]
---@field key_tables table<string, KeyBinding[]>

---@class Keymap.BindOptions
---@field name? string
---@field prefix? KeyInput
---@field keys KeyBinding[]
---@field map? string
---
---@field options Keymap.bind.options
function Keymap.prototype:bind(opts)
  assert(is.table(opts))
  local key_table
  if is.some(opts.prefix) then
    local name = opts.name or keystr(opts.prefix)
    key_table = self:key_table(name)
    local activate_key = {
      key = opts.prefix.key,
      mods = opts.prefix.mods,
      action = act.ActivateKeyTable({ name = name }),
    }
    self:bind({ activate_key }, { key_table = opts.prefix.key_table })
  else
    key_table = self.keys
  end
  for _, key in ipairs(opts) do
    assert(is.table(key))
    assert(is.string(key.key))
    assert(key.mods == nil or is.string(key.mods))
    assert(is.some(key.action))
    table.insert(key_table, key)
    if not opts.disable_default_key_bindings then
      if opts.prefix ~= nil then
        insert_clear_key_table_stack_keys(key_table)
      end
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
