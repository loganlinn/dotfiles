local HOME = os.getenv("HOME")
local DOTFILES_DIR = os.getenv("DOTFILES_DIR") or (HOME .. "/.dotfiles")
package.path = package.path .. ";" .. DOTFILES_DIR .. "/darwin/modules/hammerspoon/?.lua"
package.path = package.path .. ";" .. DOTFILES_DIR .. "/darwin/modules/hammerspoon/?/init.lua"
package.cpath = package.cpath .. ";" .. DOTFILES_DIR .. "/darwin/modules/hammerspoon/?.so"

local command = require("command")

local alert = require("hs.alert")
local application = require("hs.application")
local eventtap = require("hs.eventtap")
local fnutils = require("hs.fnutils")
local hints = require("hs.hints")
local inspect = require("hs.inspect")
local ipc = require("hs.ipc")
local logger = require("hs.logger")
local osascript = require("hs.osascript")
local pathwatcher = require("hs.pathwatcher")
local window = require("hs.window")

local CTRL = "⌃"
local ALT = "⌥"
local SHIFT = "⇧"
local GUI = "⌘"
local HYPER = CTRL .. SHIFT .. ALT .. GUI
local MEH = CTRL .. SHIFT .. ALT

local partial = fnutils.partial

local log = logger.new(hs.configdir .. "/init.lua", "debug")

ipc.cliInstall()

local configwatcher
configwatcher = pathwatcher.new(hs.configdir .. "/init.lua", function()
  if configwatcher then
    hs.reload()
  end
end)
configwatcher:start()

hints.style = "vimperator"
hints.showTitleThresh = 4
hints.titleMaxSize = 10
hints.fontSize = 30

window.animationDuration = 0.2

---------------------------------------------------------------------------------------------------
-- Keybindings
---------------------------------------------------------------------------------------------------

local lastWindow = function()
  local _, previous = next(window.orderedWindows(), 1) -- ordered from front to back, starting with current
  return previous
end
local launchOrFocus = function(name)
  return application.launchOrFocus(name)
end -- wrap to discard extra args (i.e. fnutils.some passes index)
local launchOrFocusByBundleID = function(id)
  return application.launchOrFocusByBundleID(id)
end
local appNameMatcher = function(name)
  return function(app)
    return app and app:name():find(name)
  end
end
local appBundleIDMatcher = function(bundleID)
  return function(app)
    return app and app:bundleID():find(bundleID)
  end
end
local appSwitcher = function(opts)
  local bundleIDs = type(opts.bundleID) == "string" and { opts.bundleID } or opts.bundleID or {}
  local names = type(opts.name) == "string" and { opts.name } or opts.name or {}

  local matchers = fnutils.concat(fnutils.map(bundleIDs, appBundleIDMatcher), fnutils.map(names, appNameMatcher))

  if #matchers == 0 then
    error("appSwitcher requires at least one of 'name' or 'bundleID' in opts")
  end

  local currentlyFocused = function()
    local win = window.focusedWindow()
    if win then
      local app = win:application()
      if fnutils.some(matchers, function(f)
            return f(app)
          end) then
        return true
      end
    end
    return false
  end

  local launch = function()
    return (fnutils.some(bundleIDs, launchOrFocusByBundleID) or fnutils.some(names, launchOrFocus))
  end

  return function()
    if currentlyFocused() then
      local win = (opts[1] or lastWindow)()
      if win then
        win:raise():focus()
      end
    else
      launch()
    end
    if opts.callback then
      opts.callback(opts)
    end
  end
end
local closeNotifications = function()
  log.i("Closing notifications")
  local ok, output, descriptor = osascript.javascript([===[
    function run() {
      const SystemEvents = Application("System Events");
      const NotificationCenter = SystemEvents.processes.byName("NotificationCenter");
      const isPreSequoia = (() => {
        const app = Application.currentApplication();
        app.includeStandardAdditions = true;
        const { systemVersion } = app.systemInfo();
        return parseFloat(systemVersion) < 15.0;
      })();
      const windows = NotificationCenter.windows;
      if (windows.length === 0) return;
      (isPreSequoia
        ? windows.at(0).groups.at(0).scrollAreas.at(0).uiElements.at(0).groups()
        : windows.at(0).groups.at(0).groups.at(0).scrollAreas.at(0).groups().at(0).uiElements().concat( // "Clear All" hierarchy
            windows.at(0).groups.at(0).groups.at(0).scrollAreas.at(0).groups()) // "Close" hierarchy
      ).forEach((group) => {
        const [closeAllAction, closeAction] = group.actions().reduce(
          (matches, action) => {
            switch (action.description()) {
              case "Clear All": return [action, matches[1]];
              case "Close": return [matches[0], action];
              default: return matches;
            }
          },
          [null, null],
        );
        (closeAllAction ?? closeAction)?.perform();
      });
    }
]===])
  log.i(ok, output, hs.inspect.inspect(descriptor))
end

local modes = setmetatable({}, {
  __newindex = function(self, name, mode)
    log.i("Registering mode", name)
    mode.entered = mode.entered or partial(alert, "+" .. name)
    mode.exited = mode.exited or partial(alert, "-" .. name)
    rawset(self, name, mode)
  end,
})

local function aerospaceReload()
  hs.execute("aerospace reload-config", true)
end

modes.main = hs
    .hotkey
    .modal
    .new(HYPER, "k")
    :bind(HYPER, "k", function()
      modes.main:exit()
    end) -- toggle all hotkeys
    :bind(ALT, "return", appSwitcher({ bundleID = "net.kovidgoyal.kitty", name = "Kitty" }))
    :bind(SHIFT .. ALT, "return", appSwitcher({ name = "Google Chrome" }))
    :bind(ALT, "d", appSwitcher({ name = "Zed" }))
    :bind(ALT, "e", appSwitcher({ name = "Emacs" }))
    :bind(ALT, "i", appSwitcher({ name = "Linear" }))
    :bind(ALT, "m", appSwitcher({ bundleID = "com.apple.MobileSMS", name = "Messages" }))
    :bind(ALT, "o", appSwitcher({ name = "Finder" }))
    :bind(ALT, "p", appSwitcher({ name = "Claude" }))
    :bind(ALT, "s", appSwitcher({ name = "Slack" }))
    :bind(HYPER, "a", aerospaceReload)
    :bind(HYPER, "d", hs.toggleConsole)
    :bind(HYPER, "l", hs.caffeinate.lockScreen)
    :bind(HYPER, "r", hs.reload)
    :bind(HYPER, "x", closeNotifications)
    :enter()

alert("✅ Hammerspoon")
