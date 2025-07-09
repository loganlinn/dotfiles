local hs = _G["hs"]
local _ = require("hs.ipc") -- enables `hc` CLI
local alert = require("hs.alert")
local logger = require("hs.logger")
local hotkey = require("hs.hotkey")
local log = logger.new("hammerspoon.init", "info")

----------------------------------------
-- Helpers

local partial = function(f, ...)
  local f1 = function(f, x)
    return function(...)
      return f(x, ...)
    end
  end
  for i = 1, select("#", ...) do
    f = f1(f, select(i, ...))
  end
  return f
end

local execute = function(...)
  log.i("[execute]", ...)
  return hs.execute(...)
end

local wezterm = {}

wezterm.application = hs.application.find("com.github.wez.wezterm")
  or hs.application.find("WezTerm")
  or log.w("WezTerm not found")
  or nil

wezterm.activate = function()
  return wezterm.application and wezterm.application:activate()
end

local aerospace = {}

aerospace.reload = function()
  execute("aerospace reload-config", true)
  alert("✅ Aerospace")
end

----------------------------------------
-- Hotkeys

local CTRL = "⌃"
local ALT = "⌥"
local SHIFT = "⇧"
local GUI = "⌘"
local MEH = CTRL .. SHIFT .. ALT
local HYPER = CTRL .. SHIFT .. ALT .. GUI

local launchOrFocusFn = partial(partial, hs.application.launchOrFocus)

local function lockScreen()
  hs.caffeinate.lockScreen()
end

hs.hotkey.bind(ALT, "return", wezterm.activate)
hs.hotkey.bind(SHIFT .. ALT, "return", launchOrFocusFn("Google Chrome"))
hs.hotkey.bind(ALT, "e", launchOrFocusFn("Emacs"))
hs.hotkey.bind(ALT, "m", launchOrFocusFn("Messages"))
hs.hotkey.bind(ALT, "o", launchOrFocusFn("Finder"))
hs.hotkey.bind(ALT, "p", launchOrFocusFn("Claude"))
hs.hotkey.bind(ALT, "s", launchOrFocusFn("Slack"))
hs.hotkey.bind(HYPER, "`", hs.toggleConsole)
hs.hotkey.bind(HYPER, "a", aerospace.reload)
hs.hotkey.bind(HYPER, "l", lockScreen)
hs.hotkey.bind(HYPER, "r", hs.reload)

alert("✅ Hammerspoon")
