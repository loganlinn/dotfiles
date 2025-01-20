require("hs.ipc") -- enables `hc` CLI

local log = hs.logger.new("init", "debug")

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

hs.hotkey.bind({ "alt" }, "return", function()
  -- launching nix-installed macOS apps tends to have flaws.
  -- prefer to launch by explicit path
  local _ = getAndActivate("com.github.wez.wezterm")
    or launchOrFocusSome(findNixAppPath("WezTerm"))
    or hs.application.launchOrFocus("WezTerm")
    or hs.application.launchOrFocus("Kitty")
    or hs.applicationLaunchOrFocus("Terminal")
end)

hs.hotkey.bind({ "alt" }, "g", function()
  hs.application.launchOrFocus("Gemini")
end)

hs.hotkey.bind({ "alt", "ctrl" }, "r", function()
  hs.reload()
end)
