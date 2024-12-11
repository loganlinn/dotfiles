local wezterm = require("wezterm")

local M = {}

M.Logger = function(prefix, separator)
  prefix = prefix or {}
  separator = separator or ">"
  local logger = {
    info = function(...)
      wezterm.log_info(table.unpack(prefix), separator, ...)
      return ...
    end,
    warn = function(...)
      wezterm.log_warn(table.unpack(prefix), separator, ...)
      return ...
    end,
    error = function(...)
      wezterm.log_error(table.unpack(prefix), separator, ...)
      return ...
    end,
  }
  return setmetatable(logger, {
    __call = function(...)
      logger.info(...)
    end,
  })
end

setmetatable(M, {
  __call = function(_, ...)
    return M.Logger({ ... })
  end,
})

return M
