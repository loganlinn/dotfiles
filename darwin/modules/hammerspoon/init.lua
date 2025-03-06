require("hs.ipc") -- enables `hc` CLI

local log = require("hs.logger").new("init", "info")
-- local hotkey = require "hs.hotkey"
-- local application = require "hs.application"
-- local mouse = require "hs.mouse"
-- local screen = require "hs.screen"
-- local geometry = require "hs.geometry"
-- local spaces = require "hs.spaces"
-- local timer = require "hs.timer"

local config = {
  mods = { "alt" },
  -- NOTE: make sure these don't conflict with aerospace hotkeys!
  keys = {
    ["return"] = { app = "WezTerm" },
    b = { app = "Google Chrome" },
    e = { app = "Finder" },
    m = { app = "Messages" },
    n = { app = "Obsidian" },
    p = { app = "Claude" },
    s = { app = "Slack" },
    -- f1 = { app = "System Information" },
    -- f2 = { app = "Console" },
    -- f4 = { app = "Activity Monitor" },
  },
}

local pathlib = {}

--- Expands tilde.
---@param path string
---@return string
function pathlib.expand(path)
  if path:sub(1, 1) == "~" then
    path = os.getenv("HOME") .. path:sub(2)
  end
  return path
end

function pathlib.join(dir, base)
  if dir:sub(-1) ~= "/" and base:sub(1, 1) ~= "/" then
    dir = dir .. "/"
  end
  return dir .. base
end

---@param iter string[]|function
---param name string
---@return string|nil
function pathlib.search(iter, name)
  if type(iter) ~= "function" then
    iter = ipairs(iter)
  end
  for _, path in iter do
    local pathname = pathlib.join(path, name)
    if hs.fs.attributes(pathname, "inode") then
      return pathname
    end
  end
end

function pathlib.findNixApp(name)
  return pathlib.search({
    "/Applications/Nix Apps",
    "/Applications/Nix Apps",
    "/Applications/Home Manager Apps",
  }, name .. ".app")
end

local function activateWezterm()
  log.d("activateWezterm")
  local app = hs.application.get("com.github.wez.wezterm")
  if app then
    return app:activate()
  end
  local path = pathlib.findNixApp("WezTerm")
  if path then
    return hs.application.launchOrFocus(path)
  end
end

local function bindKey(key, opts)
  if type(opts) == "function" then
    opts = { pressFn = opts }
  end
  local pressFn = opts.pressFn

  if opts.app then
    assert(not pressFn)
    local app = opts.app
    if app == "WezTerm" then
      pressFn = activateWezterm
    else
      pressFn = function()
        log.d("launchOrFocus", app)
        hs.application.launchOrFocus(app)
      end
    end
  end

  local mods = opts.mods or config.mods
  local key = opts.key or key
  local message = opts.message
  local releaseFn = opts.releaseFn
  local repeatFn = opts.repeatFn
  log.d("hs.hotkey.bind <-", mods, key, message, pressFn, releaseFn, repeatFn)
  hs.hotkey.bind(mods, key, message, pressFn, releaseFn, repeatFn)
end

hs.hotkey.bind({ "alt", "ctrl" }, "r", hs.reload)
for key, opts in pairs(config.keys) do
  bindKey(key, opts)
end
hs.alert.show("✅ Hammerspoon")
