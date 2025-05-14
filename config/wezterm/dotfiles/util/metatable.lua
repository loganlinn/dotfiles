---@alias metatable.__mode 'v'|'k'|'kv'|nil
---@alias metatable.__metatable any|nil
---@alias metatable.__tostring (fun(t):string)|nil
---@alias metatable.__gc fun(t)|nil
---@alias metatable.__add (fun(t1,t2):any)|nil
---@alias metatable.__sub (fun(t1,t2):any)|nil
---@alias metatable.__mul (fun(t1,t2):any)|nil
---@alias metatable.__div (fun(t1,t2):any)|nil
---@alias metatable.__mod (fun(t1,t2):any)|nil
---@alias metatable.__pow (fun(t1,t2):any)|nil
---@alias metatable.__unm (fun(t):any)|nil
---@alias metatable.__concat (fun(t1,t2):any)|nil
---@alias metatable.__len (fun(t):integer)|nil
---@alias metatable.__eq (fun(t1,t2):boolean)|nil
---@alias metatable.__lt (fun(t1,t2):boolean)|nil
---@alias metatable.__le (fun(t1,t2):boolean)|nil
---@alias metatable.__index table|(fun(t,k):any)|nil
---@alias metatable.__newindex table|fun(t,k,v)|nil
---@alias metatable.__call (fun(t,...):...)|nil

---@alias metamethod
---| metatable.__mode
---| metatable.__metatable
---| metatable.__tostring
---| metatable.__gc
---| metatable.__add
---| metatable.__sub
---| metatable.__mul
---| metatable.__div
---| metatable.__mod
---| metatable.__pow
---| metatable.__unm
---| metatable.__concat
---| metatable.__len
---| metatable.__eq
---| metatable.__lt
---| metatable.__le
---| metatable.__index
---| metatable.__newindex
---| metatable.__call

local wezterm = require("wezterm")

local M = {}

---@param t table
---@return metatable
function M.get_or_init(t)
  local mt = getmetatable(t)
  if mt == nil then
    mt = {}
    setmetatable(t, mt)
  end
  return mt
end

---@generic T: table, X: metamethod
---@param t T
---@param k `X`
---@return X
function M.lookup(t, k)
  local mt = getmetatable(t)
  if mt ~= nil then
    return mt[k]
  end
end

---@generic T: table
---@param t T
---@return T
function M.set_strict_index(t, enable)
  if enable == nil then
    enable = true
  end
  local mt = M.get_or_init(t)
  if mt["__index_strict_inner"] == nil then
    local inner = mt.__index or false
    if type(inner) == "table" then
      local inner_tbl = inner
      inner = function(_, k)
        return inner_tbl[k]
      end
    end
    mt["__index_strict_inner"] = inner
  end
  mt["__index_strict_mode"] = enable
  mt.__index = function(self, k)
    local mt = getmetatable(self)
    local inner = mt["__index_strict_inner"]
    local v
    if inner ~= nil then
      v = inner(self, k)
    end
    if v == nil and mt["__index_strict_mode"] then
      error("Key " .. wezterm.to_string(t) .. " not found in " .. wezterm.to_string(k))
    end
    return v
  end
  return t
end

---@generic T: table
---@param t T
---@param f metatable.__call|string
---@return T
function M.set_call_handler(t, f)
  if type(f) == "string" then
    local k = tostring(f)
    f = function(self, ...)
      return self[k](self, ...)
    end
  end
  M.get_or_init(t).__call = f
  return t
end

return M
