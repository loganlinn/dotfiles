local is = require("dotfiles.util.is")

local M = {}

---@param t table
---@param ks string[]
---@param alt? any
---@return any
function M.getin(t, ks, alt)
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
function M.get(t, k, alt)
  if type(t) ~= "table" then
    return nil
  end
  local v = t[k]
  if v == nil then
    return alt
  end
end

---@generic K
---@param t table<K, any>
---@return K[]
function M.keys(t)
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
function M.map(fun, t)
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
function M.filter(pred, t)
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
function M.filterkv(pred, t)
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
function M.selectkeys(t, ks)
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
function M.contains(t, v)
  for k, x in ipairs(t) do
    if v == x then
      return true, k
    end
  end
  return false, nil
end

---@param t table Table to check
---@return boolean `true` if `t` is empty
function M.isempty(t)
  return next(t) == nil
end

---@param t table
---@return boolean `true` if array-like table, else `false`
function M.islist(t)
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

function M.foreach(f, t)
  for k, v in pairs(t) do
    f(k, v)
  end
end

function M.iforeach(f, t)
  for k, v in ipairs(t) do
    f(k, v)
  end
end

function M.every(pred, t)
  for k, v in pairs(t) do
    if not pred(k, v) then
      return false
    end
  end
  return true
end

--- We only merge empty tables or tables that are not a list
---@private
local function can_merge(v)
  return type(v) == "table" and (M.isempty(v) or not M.islist(v))
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
function M.extend(behavior, ...)
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
function M.deep_extend(behavior, ...)
  return tbl_extend(behavior, true, ...)
end

--- Add the reverse lookup values to an existing table.
--- For example:
--- ``tbl_add_reverse_lookup { A = 1 } == { [1] = 'A', A = 1 }``
---
--- Note that this *modifies* the input.
---@param t table Table to add the reverse to
---@return table o
function M.add_reverse_lookup(t)
  local keys = M.keys(t)
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
