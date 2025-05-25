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
  keybinds = {},
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

---@class BindKeyOpts
---@field mods string[]
---@field key string
---@field app? string
---@field message? string
---@field release? string
---@param opts BindKeyOpts
local function bindKey(opts)
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

  local mods = opts.mods
  local key = opts.key or key
  local message = opts.message
  local releaseFn = opts.releaseFn
  local repeatFn = opts.repeatFn
  log.d("hs.hotkey.bind <-", mods, key, message, pressFn, releaseFn, repeatFn)
  hs.hotkey.bind(mods, key, message, pressFn, releaseFn, repeatFn)
end

--------------------------------------------------------------------------------

hs.hotkey.bind({ "alt", "ctrl" }, "r", hs.reload)

bindKey({
  mods = { "alt" },
  key = "return",
  app = "WezTerm",
})

bindKey({
  mods = { "alt", "shift" },
  key = "return",
  app = "Google Chrome",
})

bindKey({
  mods = { "alt" },
  key = "e",
  app = "Emacs",
})

bindKey({
  mods = { "alt" },
  key = "m",
  app = "Messages",
})

bindKey({
  mods = { "alt" },
  key = "n",
  app = "Obsidian",
})

bindKey({
  mods = { "alt" },
  key = "o",
  app = "Finder",
})

bindKey({
  mods = { "alt" },
  key = "p",
  app = "Claude",
})

bindKey({
  mods = { "alt" },
  key = "s",
  app = "Slack",
})

hs.alert.show("✅ Hammerspoon")
