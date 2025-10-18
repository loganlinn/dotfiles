local HOME = os.getenv("HOME")
package.path = package.path .. ";" .. HOME .. "/.dotfiles/darwin/modules/hammerspoon/?.lua"
package.path = package.path .. ";" .. HOME .. "/.dotfiles/darwin/modules/hammerspoon/?/init.lua"
package.cpath = package.cpath .. ";" .. HOME .. "/.dotfiles/darwin/modules/hammerspoon/?.so"
-- package.path = package.path
--     .. ";"
--     .. HOME
--     .. "/.luarocks/share/lua/5.4/?.lua;"
--     .. HOME
--     .. "/.luarocks/share/lua/5.4/?/init.lua"
-- package.cpath = package.cpath .. ";" .. HOME .. "/.luarocks/lib/lua/5.4/?.so"
-- package.path = package.path
--     .. ";"
--     .. HOME
--     .. "/.luarocks/share/lua/5.3/?.lua;"
--     .. HOME
--     .. "/.luarocks/share/lua/5.3/?/init.lua"
-- package.cpath = package.cpath .. ";" .. HOME .. "/.luarocks/lib/lua/5.3/?.so"

-- local fennel = require("fennel")
-- table.insert(package.loaders or package.searchers, fennel.searcher)
----------------------------------------------------------------------------------------------------
local alert = require("hs.alert")
local application = require("hs.application")
local eventtap = require("hs.eventtap")
local fnutils = require("hs.fnutils")
local hints = require("hs.hints")
local inspect = require("hs.inspect")
local ipc = require("hs.ipc")
local logger = require("hs.logger")
local pathwatcher = require("hs.pathwatcher")
local window = require("hs.window")
local osascript = require("hs.osascript")

local CTRL = "⌃"
local ALT = "⌥"
local SHIFT = "⇧"
local GUI = "⌘"
local HYPER = CTRL .. SHIFT .. ALT .. GUI
local MEH = CTRL .. SHIFT .. ALT

local contains = fnutils.contains
local partial = fnutils.partial
local split = fnutils.split

ipc.cliInstall()

hints.style = "vimperator"
hints.showTitleThresh = 4
hints.titleMaxSize = 10
hints.fontSize = 30

window.animationDuration = 0.2

local configpath = hs.configdir .. "/init.lua"

local log = logger.new(configpath, "debug")

local configwatcher
configwatcher = pathwatcher.new(configpath, function()
  if configwatcher then
    hs.reload()
  end
end)
configwatcher:start()

-- local getUserEnvs = function(names)
--   local env = {}
--   local output, ok = hs.execute([[zsh -l -c 'printenv --null "$@"' -s ]] .. table.concat(names, " "))
--   if ok then
--     local values = split(output, "\0")
--     for i = 1, #names do
--       env[names[i]] = values[i]
--     end
--   end
--   return env
-- end
-- for k, v in pairs(getUserEnvs({ "HOME", "PATH" })) do
--   log.i(k, v)
-- end

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

local function findExe(name)
  local output, ok = hs.execute([[zsh -l -c 'command -v "$1"' -s ]] .. name)
  return ok and split(output or "", "%s+", 1)[1] or nil
end

local aerospaceExe = findExe("aerospace")

local aerospace = function(command)
  local cmdline = [[/bin/sh -c '"]] .. (aerospaceExe or "aerospace") .. [[" $@' -s ]] .. tostring(command)
  log.i(cmdline)
  return hs.execute(cmdline)
end
-- log.i(aerospace("--version"))

local modes = setmetatable({}, {
  __newindex = function(self, name, mode)
    log.i("Registering mode", name)
    mode.entered = mode.entered or partial(alert, "+" .. name)
    mode.exited = mode.exited or partial(alert, "-" .. name)
    rawset(self, name, mode)
  end,
})

local switchTo = {
  terminal = appSwitcher({ bundleID = "com.github.wez.wezterm", name = "WezTerm" }),
  browser = appSwitcher({ name = "Google Chrome" }),
  editor = appSwitcher({ name = "Emacs" }),
  messenger = appSwitcher({ bundleID = "com.apple.MobileSMS", name = "Messages" }),
  explorer = appSwitcher({ name = "Finder" }),
  chat = appSwitcher({ name = "Slack" }),
}

modes.main = hs.hotkey.modal
  .new(HYPER, "k")
  :bind(HYPER, "k", function() -- toggle all hotkeys
    modes.main:exit()
  end)
  :bind(ALT, "return", switchTo.terminal)
  :bind(SHIFT .. ALT, "return", switchTo.browser)
  :bind(ALT, "'", switchTo.browser)
  :bind(ALT, "d", appSwitcher({ name = "Zed" }))
  :bind(ALT, "e", switchTo.editor)
  :bind(ALT, "i", appSwitcher({ name = "Linear" }))
  :bind(ALT, "m", switchTo.messenger)
  :bind(ALT, "o", switchTo.explorer)
  :bind(ALT, "p", appSwitcher({ name = "Claude" }))
  :bind(ALT, "s", switchTo.chat)
  :bind(HYPER, "return", switchTo.terminal)
  :bind(HYPER, "space", switchTo.browser)
  :bind(HYPER, "a", partial(aerospace, "reload-config"))
  :bind(HYPER, "o", switchTo.explorer)
  :bind(HYPER, "d", hs.toggleConsole)
  :bind(HYPER, "l", hs.caffeinate.lockScreen)
  :bind(HYPER, "r", hs.reload)
  :bind(HYPER, "x", closeNotifications)
  :enter()

--- Use Fn + `h/l/j/k` as arrow keys, `y/u/i/o` as mouse wheel, `,/.` as left/right click.
-- hs.eventtap.new(
--   { hs.eventtap.event.types.keyDown },
--   function(event)
--     log.i(hs.inspect(event))
--     local activated = event:getFlags()['fn']
--     if activated then
--       if event:getCharacters() == "h" then
--         return true, { hs.eventtap.event.newKeyEvent({}, "left", true) }
--       elseif event:getCharacters() == "l" then
--         return true, { hs.eventtap.event.newKeyEvent({}, "right", true) }
--       elseif event:getCharacters() == "j" then
--         return true, { hs.eventtap.event.newKeyEvent({}, "down", true) }
--       elseif event:getCharacters() == "k" then
--         return true, { hs.eventtap.event.newKeyEvent({}, "up", true) }
--       elseif event:getCharacters() == "y" then
--         return true, { hs.eventtap.event.newScrollEvent({ 3, 0 }, {}, "line") }
--       elseif event:getCharacters() == "o" then
--         return true, { hs.eventtap.event.newScrollEvent({ -3, 0 }, {}, "line") }
--       elseif event:getCharacters() == "u" then
--         return true, { hs.eventtap.event.newScrollEvent({ 0, -3 }, {}, "line") }
--       elseif event:getCharacters() == "i" then
--         return true, { hs.eventtap.event.newScrollEvent({ 0, 3 }, {}, "line") }
--       elseif event:getCharacters() == "," then
--         local currents = hs.mouse.getAbsolutePosition()
--         return true, { hs.eventtap.leftClick(currents) }
--       elseif event:getCharacters() == "." then
--         local currents = hs.mouse.getAbsolutePosition()
--         return true, { hs.eventtap.rightClick(currents) }
--       end
--     end
--   end
-- ):start()

-- et = hs.eventtap.new(
--   { eventtap.event.types.flagsChanged },
--   function(e)
--     local flags = e:rawFlags()
--     if flags & eventtap.event.rawFlagMasks.deviceRightCommand > 0 then
--       if not myKeysActive then
--         for _, v in ipairs(myKeys) do
--           v:enable()
--         end
--         myKeysActive = true
--       end
--     else
--       if myKeysActive then
--         for _, v in ipairs(myKeys) do
--           v:disable()
--         end
--         myKeysActive = false
--       end
--     end
--   end
-- ):start()

-- hs.loadSpoon("EmmyLua")
alert("✅ Hammerspoon")
