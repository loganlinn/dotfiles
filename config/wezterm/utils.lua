---@class utils
local M = {}

--------------------------------------------------------------------------------

M.table = {}

---@param t1 table
---@param t2? table
---@return table
function M.table.copy(t1, t2)
  t2 = t2 or {}
  for k, v in pairs(t1 or {}) do
    rawset(t2, k, v)
  end
  return t2
end

--------------------------------------------------------------------------------

M.string = {}

---@param str string
---@param start string
---@return boolean
function M.string.starts_with(str, start) return str:sub(1, #start) == start end

---@param str string
---@param ending string
---@return boolean
function M.string.ends_with(str, ending) return ending == "" or str:sub(- #ending) == ending end

--------------------------------------------------------------------------------

function M.is_darwin() return M.string.ends_with(require('wezterm').target_triple, "apple-darwin") end

function M.is_linux() return M.string.ends_with(require('wezterm').target_triple, "linux-gnu") end

function M.is_windows() return M.string.ends_with(require('wezterm').target_triple, "windows-msvc") end

--------------------------------------------------------------------------------

return M
