require("hs.ipc") -- enables `hc` CLI

local logger = require("hs.logger")

local log = logger.new("hammerspoon.init", "info")

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

local function launchOrFocusFn(app)
  return function()
    hs.application.launchOrFocus(app)
  end
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

hs.hotkey.bind("⌥", "return", activateWezterm)
hs.hotkey.bind("⌃⌥", "r", hs.reload)
hs.hotkey.bind("⇧⌥", "return", launchOrFocusFn("Google Chrome"))
hs.hotkey.bind("⌥", "e", launchOrFocusFn("Emacs"))
hs.hotkey.bind("⌥", "m", launchOrFocusFn("Messages"))
hs.hotkey.bind("⌥", "o", launchOrFocusFn("Finder"))
hs.hotkey.bind("⌥", "p", launchOrFocusFn("Claude"))
hs.hotkey.bind("⌥", "s", launchOrFocusFn("Slack"))

hs.alert.show("✅ Hammerspoon")
