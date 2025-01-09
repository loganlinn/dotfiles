local wezterm = require("wezterm")
local log = require("dotfiles.util.logger").new("dotfiles.config")

local M = {}

---@alias ConfigFunction fun(config: Config, ...: any): Config
---@alias ConfigPlugin { apply_to_config: ConfigFunction }

---@param config Config
---@param arg  ConfigFunction|ConfigPlugin|Config
---@return Config
function M:apply(config, arg, ...)
  if type(arg) == "function" then
    config = arg(config, ...) or config
  elseif type(arg) == "table" then
    if type(arg.apply_to_config) == "function" then
      config = arg.apply_to_config(config, ...)
    elseif type(arg[1]) == "function" or type(arg[1]) == "table" and type(arg[1].apply_to_config) == "function" then
      config = self:apply(config, arg[1], arg)
    else
      config = self:merge(config, arg)
    end
  else
    error("expected function or table, got " .. type(arg), 2)
  end
  return config
end

local function error_on_conflict(config, k, v, stack)
  local path = tostring(k)
  if stack then
    for _, kk in ipairs(stack) do
      path = path .. "." .. tostring(kk)
    end
  end
  error("conflict at " .. path .. ": " .. tostring(config[k]) .. " and " .. tostring(v))
end

function M:merge(config, other, stack)
  for k, v in pairs(arg) do
    if config[k] == nil then
      config[k] = v
    elseif type(config[k]) == "table" then
      if type(v) == "table" then
        if type(next(v)) == "number" then
          for _, vv in ipairs(v) do
            table.insert(config[k], vv)
          end
        else
          for kk, vv in pairs(v) do
            if config[k][kk] == nil then
              config[k][kk] = vv
            elseif config[k][kk] ~= vv then
              error("conflicting values for key " .. k .. ": " .. tostring(config[k][kk]) .. " and " .. tostring(vv))
            end
          end
        end
      end
      config[k] = M.merge(config[k], v)
    elseif config[k] ~= v then
      error("conflicting values for key " .. k .. ": " .. tostring(config[k][kk]) .. " and " .. tostring(vv))
    end
  end
  return config
end

---@param config Config
---@return Config
function M.build(config, ...)
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    log.info("applying config", arg)
    config = M:apply(config, arg) or config
  end
  return config
end

---@return Config
function M.new()
  local config = wezterm.config_builder()
  config:set_strict_mode(true)

  -- initialize tables
  config.keys = {}
  config.key_tables = {}

  return config
end

return M
