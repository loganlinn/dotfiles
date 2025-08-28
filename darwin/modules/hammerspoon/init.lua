local homedir = os.getenv("HOME")

package.path = package.path .. ";" .. homedir .. "/.dotfiles/darwin/modules/hammerspoon/?.lua"
package.path = package.path .. ";" .. homedir .. "/.dotfiles/darwin/modules/hammerspoon/?/init.lua"
package.cpath = package.cpath .. ";" .. homedir .. "/.dotfiles/darwin/modules/hammerspoon/?.so"
-- package.path = package.path
--     .. ";"
--     .. homedir
--     .. "/.luarocks/share/lua/5.4/?.lua;"
--     .. homedir
--     .. "/.luarocks/share/lua/5.4/?/init.lua"
-- package.cpath = package.cpath .. ";" .. homedir .. "/.luarocks/lib/lua/5.4/?.so"
-- package.path = package.path
--     .. ";"
--     .. homedir
--     .. "/.luarocks/share/lua/5.3/?.lua;"
--     .. homedir
--     .. "/.luarocks/share/lua/5.3/?/init.lua"
-- package.cpath = package.cpath .. ";" .. homedir .. "/.luarocks/lib/lua/5.3/?.so"

-- local fennel = require("fennel")
-- table.insert(package.loaders or package.searchers, fennel.searcher)

local log = hs.logger.new("init.lua", "debug")

hs.ipc.cliInstall()
hs.hints.style = "vimperator"
hs.hints.showTitleThresh = 4
hs.hints.titleMaxSize = 10
hs.hints.fontSize = 30
hs.window.animationDuration = 0.2

local config_watcher
config_watcher = hs.pathwatcher
  .new(hs.configdir .. "/init.lua", function()
    if config_watcher then
      hs.reload()
    end
  end)
  :start()

---------------------------------------------------------------------------------------------------
-- Keybindings
---------------------------------------------------------------------------------------------------
local CTRL = "⌃"
local ALT = "⌥"
local SHIFT = "⇧"
local GUI = "⌘"
local HYPER = CTRL .. SHIFT .. ALT .. GUI
-- local MEH = CTRL .. SHIFT .. ALT

local partial = hs.fnutils.partial
local contains = hs.fnutils.contains
local launchOrFocus = hs.application.launchOrFocus
local launchOrFocusFn = partial(partial, launchOrFocus)
local appSwitcher = function(hints, focusCallback)
  if type(hints) == "string" then
    hints = { hints }
  end
  return function()
    local winFocus = hs.window.focusedWindow()
    if winFocus then
      local appFocus = winFocus:application()
      -- Match bundle identifier or application name
      local isFocus = contains(hints, appFocus:bundleID()) or contains(hints, appFocus:name())
      if isFocus then
        local _, winPrev = next(hs.window.orderedWindows(), 1) -- ordered from front to back, starting with current
        if winPrev then
          winPrev:raise():focus()
        end
        return
      end
    end
    for _, hint in ipairs(hints) do
      if launchOrFocus(hint) then
        if focusCallback then
          focusCallback(hs.window.focusedWindow())
        end
        return
      end
    end
  end
end
-- local windowMatches = function(window, selectors)
--   if type(selectors) == "string" then
--     selectors = { selectors }
--   end
--   local bundleID = window:application():bundleID()
--   if contains(selectors, bundleID) then
--     log.d("Matched window bundleID:", bundleID)
--     return true
--   end
--   local title = window:application():title()
--   for _, sel in pairs(selectors) do
--     if string.sub(title, 1, #sel) == sel then
--       log.d("Matched window title:", title, sel)
--       return true
--     end
--   end
--   return false
-- end
-- local focusGroupFn = function(selectors)
--   if type(selectors) == "string" then
--     selectors = { selectors }
--   end
--   return function()
--     local window = nil
--     if windowMatches(hs.window.focusedWindow(), selectors) then
--       -- app has focus, find last matching window
--       for _, w in pairs(hs.window.orderedWindows()) do
--         if windowMatches(w, selectors) then
--           window = w -- remember last match
--         end
--       end
--     else
--       -- app does not have focus, find first matching window
--       for _, w in pairs(hs.window.orderedWindows()) do
--         if windowMatches(w, selectors) then
--           window = w
--           break -- break on first match
--         end
--       end
--     end
--     if window then
--       window:raise():focus()
--     else
--       hs.alert.show("No window open for " .. hs.inspect(selectors))
--     end
--   end
-- end
local closeNotifications = function()
  log.i("Closing notifications")
  hs.osascript.javascript([===[
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
end
local aerospaceReloadConfig = function()
  hs.execute("zsh -lc 'aerospace reload-config'")
end

local modes = setmetatable({}, {
  __newindex = function(self, name, mode)
    log.i("Registering mode", name)
    mode.entered = mode.entered or partial(hs.alert, "+" .. name)
    mode.exited = mode.exited or partial(hs.alert, "-" .. name)
    rawset(self, name, mode)
  end,
})

modes.main = hs
  .hotkey
  .modal
  .new(HYPER, "k")
  :bind(HYPER, "k", function() -- toggle all hotkeys
    modes.main:exit()
  end)
  :bind(ALT, "return", appSwitcher({ "com.github.wez.wezterm", "WezTerm" }))
  :bind(SHIFT .. ALT, "return", appSwitcher("Google Chrome"))
  :bind(ALT, "e", appSwitcher("Emacs"))
  :bind(ALT, "i", appSwitcher("Linear"))
  :bind(ALT, "m", appSwitcher("Messages"))
  :bind(ALT, "o", appSwitcher("Finder"))
  :bind(ALT, "p", appSwitcher("Claude"))
  :bind(ALT, "s", appSwitcher("Slack"))
  :bind(HYPER, "space", appSwitcher("Google Chrome"))
  :bind(HYPER, "return", appSwitcher("Ghostty"))
  :bind(HYPER, "a", aerospaceReloadConfig)
  :bind(HYPER, "o", appSwitcher("Finder"))
  :bind(HYPER, "d", hs.toggleConsole)
  :bind(HYPER, "l", hs.caffeinate.lockScreen)
  :bind(HYPER, "r", hs.reload)
  -- :bind(HYPER, "s", hs.hints.windowHints)
  :bind(HYPER, "x", closeNotifications)
  :bind(HYPER, "F1", function()
    hs.alert("F1")
  end)
  :bind(HYPER, "F2", function()
    log.i(hs.inspect(hs.eventtap.checkKeyboardModifiers(true)))
    hs.alert("F2")
  end)
  :bind(HYPER, "F3", function()
    hs.alert("F3")
  end)
  :bind(HYPER, "F4", function()
    hs.alert("F4")
  end)
  :bind(HYPER, "F5", function()
    hs.alert("F5")
  end)
  :bind(HYPER, "F6", function()
    hs.alert("F6")
  end)
  :bind(HYPER, "F7", function()
    hs.alert("F7")
  end)
  :bind(HYPER, "F8", function()
    hs.alert("F8")
  end)
  :bind(HYPER, "F9", function()
    hs.alert("F9")
  end)
  :enter()

-- local aws_menubar = hs.menubar.new(true, "aws"):setClickCallback(function(mods)
--   log.i("menubar clicked", hs.inspect(mods))
-- end)

-- hs.timer
--     .doEvery(60, function()
--       local title = "aws"
--       local stdout, ok = hs.execute(homedir .. "/.dotfiles/bin/aws-sso-timeout")
--       if ok then
--         local seconds = tonumber(stdout)
--         if seconds then
--           local hours = math.floor(seconds / 3600)
--           local minutes = math.floor(math.fmod(seconds, 3600) / 60)
--           title = title .. string.format("[%02d:%02d]", hours, minutes)
--         end
--       end
--       aws_menubar:setTitle(title)
--     end)
--     :start()
--     :fire()

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

-- hs.loadSpoon("EmmyLua")
hs.alert("✅ Hammerspoon")
