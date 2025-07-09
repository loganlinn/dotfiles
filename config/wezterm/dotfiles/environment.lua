local wezterm = require("wezterm")
local util = require("dotfiles.util")

local M = {}

function M.get(config, name, fallback)
  if not config.set_environment_variables then
    return fallback
  end
  local value = config.set_environment_variables[name]
  if value == nil then
    return fallback
  end
  return value
end

function M.set(config, name, value)
  if not config.set_environment_variables then
    config.set_environment_variables = {}
  end
  config.set_environment_variables[name] = value
  return config
end

function M.path_add(config, name, additional_path, separator)
  separator = separator or ":"
  if type(additional_path) == "table" then
    additional_path = table.concat(additional_path, separator)
  end
  if not additional_path or additional_path == "" then
    return config
  end
  local updated_path = additional_path
  local current_path = M.get(config, name)
  if current_path ~= "" then
    updated_path = separator .. current_path
  end
  return M.set(config, name, updated_path)
end

function M.PATH_add(config, ...)
  M.path_add(config, "PATH", { ... })
end

function M.apply_to_config(config)
  local env = {}
  if util.is_darwin() then
    M.PATH_add(config, "/opt/homebrew/bin", "/opt/homebrew/sbin")
  end
  return config
end

return M
