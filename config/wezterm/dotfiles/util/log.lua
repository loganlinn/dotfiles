local wezterm = require("wezterm")

local M = {}

M.info = wezterm.log_info
M.warn = wezterm.log_warn
M.error = wezterm.log_error
M.spy = function(...)
  M.info("spy:", ...)
  return select(select("#", ...), ...)
end

setmetatable(M, { __call = M.info })

return M
