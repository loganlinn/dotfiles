---@class dotfiles.util.is
---@field boolean fun(v: any): boolean
---@field number fun(v: any): boolean
---@field string fun(v: any): boolean
---@field table fun(v: any): boolean
---@field thread fun(v: any): boolean
---@field userdata fun(v: any): boolean
local M = {}

for _, t in ipairs({ "boolean", "number", "string", "userdata", "thread", "table" }) do
  M[t:gsub("^%l", string.upper)] = function(v)
    return type(v) == t
  end
end

---@param v any
---@param t type
---@return boolean
function M.a(v, t)
  return type(v) == t
end

---@param v any
---@return boolean
function M.none(v)
  return v == nil
end

M.null = M.none

---@param v any
---@return boolean
function M.some(v)
  return not M.none(v)
end

---@param v any
---@return boolean
function M.fn(v)
  return type(v) == "function"
end

---@param v any
---@return boolean
function M.callable(v)
  if M.fn(v) then
    return true
  elseif not M.table(v) then
    return false
  else
    local mt = getmetatable(v)
    return type(mt) == "table" and type(mt.__call) == "function"
  end
end

---@param v any
---@return boolean
function M.empty(v)
  return M.none(v) or (#v == 0)
end

---@param a any
---@param b any
---@return boolean
function M.gt(a, b)
  return a > b
end

---@param a any
---@param b any
---@return boolean
function M.lt(a, b)
  return a < b
end

---@param a any
---@param b any
---@return boolean
function M.gte(a, b)
  return a >= b
end

---@param a any
---@param b any
---@return boolean
function M.lte(a, b)
  return a <= b
end

---@param a any
---@param b any
---@return boolean
function M.eq(a, b)
  return a == b
end

---@param a any
---@param b any
---@return boolean
function M.ne(a, b)
  return a ~= b
end

return M
