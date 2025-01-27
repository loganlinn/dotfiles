require("hs.ipc") -- enables `hc` CLI

LeftRightHotkey = hs.loadSpoon("LeftRightHotkey")

local log = hs.logger.new("init", "debug")
local hyper = { "cmd", "ctrl", "alt", "shift" }
local home_dir = os.getenv("HOME") or "/Users/logan"

---@param path string
---@return string|nil
local function existingPath(path)
  if hs.fs.attributes(path, "inode") then
    return path
  end
end

local function findNixAppPath(name)
  local filename = name .. ".app"
  return existingPath("/Applications/Nix Apps/" .. filename)
    or existingPath(home_dir .. "/Applications/Nix Apps/" .. filename)
    or existingPath(home_dir .. "/Applications/Home Manager Apps/" .. filename)
end

local function activateApp(app)
  local app = hs.application.get(app)
  if app then
    return app:activate()
  end
end

local function launchOrFocus(app)
  if app then
    return hs.application.launchOrFocus(app)
  end
end

local function activateTerminal()
  -- launching nix-installed macOS apps tends to have flaws.
  -- prefer to launch by explicit path
  local _ = activateApp("com.github.wez.wezterm")
    or launchOrFocus(findNixAppPath("WezTerm"))
    or launchOrFocus("Terminal")
end

-- LeftRightHotkey:start()
local appHotkey = function(opts)
  local bind = opts.bind or hs.hotkey.bind
  local mods = opts.mods or { "alt" } -- LeftRightHotkey.bind, { "rAlt" }
  local key = assert(opts[1])
  local app = assert(opts[2])
  local message = opts.message or opts.app
  hs.inspect(bind(mods, key, message, function()
    hs.application.launchOrFocus(app)
  end))
end

hs.hotkey.bind({ "alt", "ctrl" }, "r", hs.reload)
hs.hotkey.bind({ "alt" }, "return", activateTerminal)
appHotkey({ "g", "Gemini" })
-- appHotkey({ "z", "Zoom" })
appHotkey({ "s", "Slack" })
appHotkey({ "m", "Messages" })
appHotkey({ "o", "Obsidian" })
appHotkey({ "e", "Finder" })
appHotkey({ "p", "1Password" })
-- appHotkey({ ",", "System Settings" })
appHotkey({ "f1", "System Information" })
appHotkey({ "f2", "Console" })
appHotkey({ "f4", "Activity Monitor" })

hs.alert.show("✅ Hammerspoon")
