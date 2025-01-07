local wezterm = require("wezterm")

-- local class = require("30log")
--
-- local INFO, WARN, ERROR = "info", "warn", "error"
--
-- ---@alias Logger.level "info"|"warn"|"error"
-- ---@class Logger
-- ---@field level Logger.level
-- ---@field label string
-- ---@field handlers table<Logger.level, fun(...:any):any>
-- local Logger = class("Logger", {
--   label = "",
--   level = INFO,
--   handlers = {
--     [INFO] = wezterm.log_info,
--     [WARN] = wezterm.log_warn,
--     [ERROR] = wezterm.log_error,
--   },
-- })
--
-- function Logger:format(...)
--   return self.label, ...
-- end
--
-- function Logger:log(level, ...)
--   return pcall(self.handlers[level or self.level] or print, self:format(...))
-- end
--
-- function Logger:info(...)
--   return self:log(INFO, ...)
-- end
--
-- function Logger:warn(...)
--   return self:log(WARN, ...)
-- end
--
-- function Logger:error(...)
--   return self:log(ERROR, ...)
-- end

local bind = function(f, ...)
  local t = { ... }
  return function(...)
    return f(table.unpack(t), ...)
  end
end

local function spy_with(f)
  return function(...)
    f(...)
    return ...
  end
end

local logger = {}

function logger.new(options)
  options = type(options) == "string" and { name = options } or options or {}

  local display_name = wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { AnsiColor = "Fuchsia" } },
    { Text = tostring(options.name or "anonymous") },
    "ResetAttributes",
    { Text = ":" },
  })

  local log = {
    info = spy_with(bind(wezterm.log_info, display_name)),
    warn = spy_with(bind(wezterm.log_warn, display_name)),
    error = spy_with(bind(wezterm.log_error, display_name)),
  }

  return log
end

setmetatable(logger, {
  __call = function(_, ...)
    return logger.new({ ... })
  end,
})

return logger
