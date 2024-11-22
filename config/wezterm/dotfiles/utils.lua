local wezterm = require("wezterm")

--------------------------------------------------------------------------------
---@class dotfiles.utils
local M = {}

M.complement = function(f)
  return function(...)
    return not f(...)
  end
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

---@class dotfiles.utils.is
local is = {}

---@param v any
---@param type_name "nil"|"boolean"|"number"|"string"|"userdata"|"function"|"thread"|"table"
---@return boolean
function is.a(v, type_name)
  return type(v) == type_name
end

---@param v any
---@return boolean
function is.boolean(v)
  return is.a(v, "boolean")
end

---@param v any
---@return boolean
function is.number(v)
  return is.a(v, "number")
end

---@param v any
---@return boolean
function is.string(v)
  return is.a(v, "string")
end

---@param v any
---@return boolean
function is.userdata(v)
  return is.a(v, "userdata")
end

---@param v any
---@return boolean
function is.fn(v)
  return is.a(v, "function")
end

---@param v any
---@return boolean
function is.thread(v)
  return is.a(v, "thread")
end

---@param v any
---@return boolean
function is.table(v)
  return is.a(v, "table")
end

---@param v any
---@return boolean
function is.null(v)
  return v == nil or is.a(v, "nil")
end

is.void = is.null
is.some = M.complement(is.null)

---@param v any
---@return boolean
function is.empty(v)
  return (v == nil) or (is.string(v) and v == "") or (is.table(v) and #v == 0)
end

-- for fun, support: is(123).number()
local is_value_metatable = {
  __index = function(self, index)
    local f = is[index]
    if f then
      return function(...)
        return f(self.value, ...)
      end
    end
  end,
}

is = setmetatable(is, {
  __call = function(self, v)
    return setmetatable({ value = v }, is_value_metatable)
  end,
})

M.is = is

--------------------------------------------------------------------------------
---@class dotfiles.utils.tbl
local tbl = {}
M.tbl = tbl

---@param t table
---@param ks string[]
---@param alt? any
---@return any
function tbl.getin(t, ks, alt)
  if type(t) ~= "table" then
    return nil
  end
  if #ks == 0 then
    return alt
  end
  for i, k in ipairs(ks) do
    t = t[k]
    if t == nil or type(t) ~= "table" and next(ks, i) then
      return alt
    end
  end
  return t
end

---@param t table
---@param k string
---@param alt? any
---@return any
function tbl.get(t, k, alt)
  if type(t) ~= "table" then
    return nil
  end
  return M.coalesce(t[k], alt)
end

---@generic K
---@param t table<K, any>
---@return K[]
function tbl.keys(t)
  local ks = {}
  for k, _ in pairs(t) do
    table.insert(ks, k)
  end
  return ks
end

---@generic K
---@generic V1
---@generic V2
---@param fun fun(k: K, v: V1): V2
---@param t table<K, V1>
---@return table<K, V2>
function tbl.map(fun, t)
  local o = setmetatable({}, getmetatable(t))
  for k, v in pairs(t) do
    rawset(o, k, fun(k, v))
  end
  return o
end

---@generic V
---@param pred fun(value: V): boolean
---@param t V[]
---@return V[]
function tbl.filter(pred, t)
  local o = {}
  for _, v in pairs(t) do
    if pred(v) then
      table.insert(o, v)
    end
  end
  return o
end

---@generic K
---@generic V
---@param pred fun(key: K, value: V): boolean
---@param t table<K, V>
---@return table<K, V>
function tbl.filterkv(pred, t)
  local o = {}
  for k, v in pairs(t) do
    if pred(k, v) then
      o[k] = v
    end
  end
  return o
end

---@generic K
---@generic V
---@param t table<any, V>
---@param ks K[]
---@return table <K, V>
function tbl.selectkeys(t, ks)
  local o = {}
  for k in pairs(ks) do
    if not is.null(t[k]) then
      table.insert(o, v)
    end
  end
  return o
end

---@generic K
---@param t table<K, any>
---@param v any
---@return boolean, K|nil
function tbl.contains(t, v)
  for k, x in ipairs(t) do
    if v == x then
      return true, k
    end
  end
  return false, nil
end

---@param t table Table to check
---@return boolean `true` if `t` is empty
function tbl.isempty(t)
  return next(t) == nil
end

---@param t table
---@return boolean `true` if array-like table, else `false`
function tbl.islist(t)
  if type(t) ~= "table" then
    return false
  end
  local count = 0
  for k, _ in pairs(t) do
    if type(k) ~= "number" then
      return false
    end
    count = count + 1
    if count > 64 then
      break
    end
  end
  return count > 0
end

function tbl.foreach(f, t)
  for k, v in pairs(t) do
    f(k, v)
  end
end

function tbl.iforeach(f, t)
  for k, v in ipairs(t) do
    f(k, v)
  end
end

--- We only merge empty tables or tables that are not a list
---@private
local function can_merge(v)
  return type(v) == "table" and (tbl.isempty(v) or not tbl.islist(v))
end

---@private
local function tbl_extend(behavior, deep_extend, ...)
  if behavior ~= "error" and behavior ~= "keep" and behavior ~= "force" then
    error('invalid "behavior": ' .. tostring(behavior))
  end

  if select("#", ...) < 2 then
    error("wrong number of arguments (given " .. tostring(1 + select("#", ...)) .. ", expected at least 3)")
  end

  local ret = {}

  for i = 1, select("#", ...) do
    local t = select(i, ...)
    if t then
      for k, v in pairs(t) do
        if deep_extend and can_merge(v) and can_merge(ret[k]) then
          ret[k] = tbl_extend(behavior, true, ret[k], v)
        elseif behavior ~= "force" and ret[k] ~= nil then
          if behavior == "error" then
            error("key found in more than one map: " .. k)
          end -- Else behavior is "keep".
        else
          ret[k] = v
        end
      end
    end
  end
  return ret
end

---@param behavior string Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
---@param ... table Two or more map-like tables
---@return table Merged table
function tbl.extend(behavior, ...)
  return tbl_extend(behavior, false, ...)
end

--- Merges recursively two or more map-like tables.
---
---@generic T1: table
---@generic T2: table
---@param behavior "error"|"keep"|"force" (string) Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
---@param ... T2 Two or more map-like tables
---@return T1|T2 (table) Merged table
function tbl.deep_extend(behavior, ...)
  return tbl_extend(behavior, true, ...)
end

--- Add the reverse lookup values to an existing table.
--- For example:
--- ``tbl_add_reverse_lookup { A = 1 } == { [1] = 'A', A = 1 }``
---
--- Note that this *modifies* the input.
---@param t table Table to add the reverse to
---@return table o
function tbl.add_reverse_lookup(t)
  local keys = tbl.keys(t)
  for _, k in ipairs(keys) do
    local v = t[k]
    if t[v] then
      error(
        string.format(
          "The reverse lookup found an existing value for %q while processing key %q",
          tostring(v),
          tostring(k)
        )
      )
    end
    t[v] = k
  end
  return t
end

--------------------------------------------------------------------------------
---@class dotfiles.utils.safe
local safe = {}
M.safe = safe

---@generic V
---@param v any
---@param t `V`
---@param label? string
---@return V
function safe.isa(v, t, label)
  if type(v) ~= t then
    local msg = "expected " .. t .. ", got " .. type(v)
    if label then
      msg = tostring(label) .. ": " .. msg
    end
    error(msg)
  end
  return v
end

---@param v any
---@param label? string
---@return string
function safe.isstring(v, label)
  return safe.isa(v, "string", label)
end

---@param v any
---@param label? string
---@return table
function safe.istable(v, label)
  return safe.isa(v, "table", label)
end

---@param v any
---@param label? string
---@return boolean
function safe.isboolean(v, label)
  return safe.isa(v, "boolean", label)
end

---@param v any
---@param label? string
---@return number
function safe.isnumber(v, label)
  return safe.isa(v, "number", label)
end

---@param v any
---@param label? string
---@return nil
function safe.isnil(v, label)
  return safe.isa(v, "nil", label)
end

---@param t any
---@param k any
---@param alt? string
---@return string
function safe.getstring(t, k, alt)
  return safe.isstring(tbl.get(t, k, alt), k)
end

---@param t any
---@param k any
---@param alt? table
---@return table
function safe.gettable(t, k, alt)
  return safe.istable(tbl.get(t, k, alt), k)
end

---@param t any
---@param k any
---@param alt? boolean
---@return boolean
function safe.getboolean(t, k, alt)
  return safe.isboolean(tbl.get(t, k, alt), k)
end

---@param t any
---@param k any
---@param alt? number
---@return number
function safe.getnumber(t, k, alt)
  return safe.isnumber(tbl.get(t, k, alt), k)
end

---@param t any
---@param k any
---@return nil
function safe.getnil(t, k)
  return safe.isnil(safe.istable(t)[k], k)
end

--------------------------------------------------------------------------------

---@class dotfiles.utils.str
local str = {}
M.str = str

---@param s string
---@param prefix string
---@return boolean
function str.startswith(s, prefix)
  return safe.isstring(s):sub(1, #prefix) == prefix
end

---@param s string
---@param suffix string
---@return boolean
function str.endswith(s, suffix)
  return suffix == "" or safe.isstring(s):sub(-#suffix) == suffix
end

--------------------------------------------------------------------------------

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
function M.platform_cond(t)
  if M.is_linux() then
    return t.linux
  elseif M.is_darwin() then
    return t.darwin
  elseif M.is_windows() then
    return t.windows
  end
end

--------------------------------------------------------------------------------
-- -- WIP WIP WIP WIP
-- ---@class dotfiles.utils.KeyTable
-- ---@field apply_to_config fun(config: table): table
-- local KeyTable = {}
-- M.KeyTable = KeyTable
--
-- ---@type metatable
-- local KeyTable_MT = {}
--
-- ---@pararm args table
-- ---@return dotfiles.utils.KeyTable
-- function KeyTable.new(args)
--   safe.istable(args)
--   local mods = safe.getstring(args, "mods", "LEADER")
--   local key = safe.getstring(args, "key")
--   local name = safe.getstring(args, "name", mods .. "_" .. key)
--
--   local action = {
--     name = name,
--     -- one_shot = safe.getboolean(args, "one_shot", true),
--     -- timeout_milliseconds = safe.getnumber(args, "timeout_milliseconds", math.maxinteger),
--     -- until_unknown = safe.getboolean(args, "until_unknown", true),
--     -- replace_current = safe.getboolean(args, "replace_current", false),
--     -- prevent_fallback = safe.getboolean(args, "prevent_fallback", false),
--   }
--
--   local key_table
--   if tbl.islist(args[1]) then
--     key_table = args[1]
--   else
--     key_table = {}
--     for k, v in pairs(args[1]) do
--       if type(k) ~= "string" then
--         error("expected string, got " .. type(v))
--       end
--       if type(v) ~= "table" then
--         error("expected table, got " .. type(v))
--       end
--       table.insert(key_table, {
--         key = safe.isstring(k),
--         action = wezterm.action.Multiple({
--           (wezterm.action_callback(function()
--             wezterm.log_info("key table:", name, "action:", v)
--           end)),
--           v,
--         }),
--       })
--     end
--   end
--
--   return setmetatable({
--     args = args,
--     key_table = key_table,
--     apply_to_config = function(config)
--       local config_key_tables = safe.gettable(config, "key_tables", {})
--       safe.getnil(config_key_tables, name)
--       config_key_tables[name] = key_table
--       config.key_tables = config_key_tables
--
--       local config_keys = safe.gettable(config, "keys", {})
--       table.insert(config_keys, {
--         key = args.key,
--         mods = args.mods,
--         action = wezterm.action.Multiple({
--           wezterm.action.ActivateKeyTable(action),
--           (wezterm.action_callback(function()
--             wezterm.log_info("key table:", name, "activating")
--           end)),
--         }),
--       })
--       config.keys = config_keys
--
--       return config
--     end,
--   }, KeyTable_MT)
-- end

function M.def_key_table(config, params)
  local name = safe.getstring(params, "name")
  local key_table = {}
  for _, v in ipairs(params) do
    table.insert(key_table, v)
  end
  config.key_tables = config.key_tables or {}
  config.key_tables[name] = key_table

  if params.key then
    table.insert(config.keys, {
      key = params.key,
      mods = params.mods or "LEADER",
      action = act.ActivateKeyTable({ name = name }),
    })
  end
end

--------------------------------------------------------------------------------
--- Helpers for debug overlay (https://github.com/wez/wezterm/discussions/5989)
local dbg = {}
M.dbg = dbg

function dbg.iswindow(x)
  return type(x) == "userdata" and is.fn(x.window_id)
end

function dbg.window(...)
  for i = 1, select("#", ...) do
    local w = select(i, ...)
    if dbg.iswindow(w) then
      return w
    end
  end
  if dbg.iswindow(_G["window"]) then
    return _G["window"]
  end
  error("window was not passed or available as global")
end

function dbg.getconfig(...)
  return dbg.getwindow(...):get_effective_config()
end

function dbg.log_events(...)
  for _, event in ipairs({ ... }) do
    wezterm.on(event, function(...)
      wezterm.log_info("event emitted:", event, "args:", { ... })
    end)
  end
end

-- https://wezfurlong.org/wezterm/config/lua/window-events/index.html
dbg.WINDOW_EVENTS = {
  "augment-command-palette",
  "bell",
  "format-tab-title",
  "format-window-title",
  "new-tab-button-click",
  "open-uri",
  "update-right-status",
  "update-status",
  "user-var-changed",
  "window-config-reloaded",
  "window-focus-changed",
  "window-resized",
}

function dbg.log_window_events()
  dbg.log_events(table.unpack(dbg.WINDOW_EVENTS))
end

-- function _G.log_config(...)
--   local config = get_config(select(1, ...))
--   local ks = {...}
--   if #ks == 0 then
--   end
-- end

--------------------------------------------------------------------------------
---@class dotfiles.utils.act
local act = {}
M.act = act

--------------------------------------------------------------------------------
---@class dotfiles.utils.act
local key = {}
M.key = key

key.create = function(key, mods, action)
  return {
    key = key,
    mods = mods,
    action = action,
  }
end

return M
