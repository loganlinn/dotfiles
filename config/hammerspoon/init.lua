require("hs.ipc") -- enables `hc` CLI

LeftRightHotkey = hs.loadSpoon("LeftRightHotkey")

local log = hs.logger.new("init", "debug")

hs.hotkey.bind({ "alt", "ctrl" }, "r", function()
  log.i("hs.reload", hs.reload())
end)

---@return string|nil
local function existing_path_or_nil(path)
  if hs.fs.attributes(path, "inode") then
    return path
  end
end

local home_dir = "/Users/" .. os.getenv("HOME")
local function findNixAppPath(name)
  local name_ext = name .. ".app"
  return existing_path_or_nil("/Applications/Nix Apps/" .. name_ext)
    or existing_path_or_nil(home_dir .. "/Applications/Nix Apps/" .. name_ext)
    or existing_path_or_nil(home_dir .. "/Applications/Home Manager Apps/" .. name_ext)
end

local function getAndActivate(app_name)
  local app = hs.application.get(app_name)
  if app then
    return app:activate()
  end
end

local function launchOrFocusSome(app)
  if app then
    return hs.application.launchOrFocus(app)
  end
end

local function activateTerminal()
  -- launching nix-installed macOS apps tends to have flaws.
  -- prefer to launch by explicit path
  local _ = getAndActivate("com.github.wez.wezterm")
    or launchOrFocusSome(findNixAppPath("WezTerm"))
    or hs.application.launchOrFocus("WezTerm")
    or hs.application.launchOrFocus("Kitty")
    or hs.applicationLaunchOrFocus("Terminal")
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

hs.hotkey.bind({ "alt" }, "return", activateTerminal)
appHotkey({ "g", "Gemini" })
-- appHotkey({ "z", "Zoom" })
appHotkey({ "s", "Slack" })
appHotkey({ "m", "Messages" })
appHotkey({ "o", "Obsidian" })
appHotkey({ "f", "Finder" })
appHotkey({ "p", "1Password" })
appHotkey({ ",", "System Settings" })
appHotkey({ "f1", "System Information" })
appHotkey({ "f2", "Console" })
appHotkey({ "f4", "Activity Monitor" })

hs.alert.show("✅ Hammerspoon")
