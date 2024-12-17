local wezterm = require("wezterm")

local __name__ = "exepath"
local log = require("dotfiles.util.logger").new(__name__)

local function cache_get(command_name)
  return (wezterm.GLOBAL[__name__] or {})[command_name]
end

local function cache_set(command_name, executable_path)
  local cache = wezterm.GLOBAL[__name__] or {}
  cache[command_name] = executable_path
  wezterm.GLOBAL[__name__] = cache
end

---@param command_name string
---@param disable_cache? boolean
---@return string?
return function(command_name, disable_cache)
  local path = not disable_cache and cache_get(command_name)

  if not path then
    log.info("resolving executable path:", command_name)

    local ok, stdout = log.info(wezterm.run_child_process({
      "/usr/bin/env",
      "zsh",
      "-l",
      "-c",
      [[command -v "$@"]],
      "-s",
      command_name,
    }))

    if ok then
      path = string.gsub(stdout, "%s*$", "")
      if not disable_cache then
        cache_set(command_name, path)
      end
    end
  end

  return path
end
