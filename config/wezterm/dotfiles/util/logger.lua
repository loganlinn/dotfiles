local wezterm = require("wezterm")

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

logger.new = function(options)
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

  function log.emit(...)
    log.info("[emit]", ...)
    return wezterm.emit(...)
  end

  return log
end

local default = logger.new()

setmetatable(logger, {
  __call = function(_, ...)
    return logger.new({ ... })
  end,
})

return logger
