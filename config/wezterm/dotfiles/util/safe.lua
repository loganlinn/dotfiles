local is = require("dotfiles.util.is")
local tbl = require("dotfiles.util.tbl")

---@class dotfiles.util.safe
local M = {}

---@generic V
---@param v any
---@param t `V`
---@param label? string
---@return V
function M.isa(v, t, label)
  if is.a(v, t) then
    return v
  end
  local msg = "expected " .. t .. ", got " .. type(v)
  if label then
    msg = tostring(label) .. ": " .. msg
  end
  error(msg)
end

---@generic V
---@param v V|any
---@param label? string
---@return V
function M.issome(v, label)
  if is.some(v) then
    return v
  end
  local msg = "expected non-nil value, got " .. type(v)
  if label then
    msg = tostring(label) .. ": " .. msg
  end
  error(msg)
end

---@param v any
---@param label? string
---@return string
function M.isstring(v, label)
  return M.isa(v, "string", label)
end

---@param v any
---@param label? string
---@return table
function M.istable(v, label)
  return M.isa(v, "table", label)
end

---@param v any
---@param label? string
---@return boolean
function M.isboolean(v, label)
  return M.isa(v, "boolean", label)
end

---@param v any
---@param label? string
---@return number
function M.isnumber(v, label)
  return M.isa(v, "number", label)
end

---@param v any
---@param label? string
---@return nil
function M.isnil(v, label)
  return M.isa(v, "nil", label)
end

---@generic K
---@generic V
---@param t table<K, V>
---@param k K
---@param alt? V
---@param label? string
---@return V
function M.getsome(t, k, alt, label)
  return M.issome(tbl.get(t, k, alt), label or tostring(k))
end

---@param t any
---@param k any
---@param alt? boolean
---@param label? string
---@return boolean
function M.getboolean(t, k, alt, label)
  return M.isboolean(tbl.get(t, k, alt), label or tostring(k))
end

---@param t any
---@param k any
---@param alt? number
---@param label? string
---@return number
function M.getnumber(t, k, alt, label)
  return M.isnumber(tbl.get(t, k, alt), label or tostring(k))
end

---@param t any
---@param k any
---@param alt? string
---@param label? string
---@return string
function M.getstring(t, k, alt, label)
  return M.isstring(tbl.get(t, k, alt), label or tostring(k))
end

---@param t any
---@param k any
---@param alt? table
---@param label? string
---@return table
function M.gettable(t, k, alt, label)
  return M.istable(tbl.get(t, k, alt), label or tostring(k))
end

return M
