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
local hotkey = require("hs.hotkey")
local inspect = require("hs.inspect")
local ipc = require("hs.ipc")
local keycodes = require("hs.keycodes")
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

local execute = function(...)
	log.i("execute ->", inspect({ ... }))
	local results = table.pack(pcall(hs.execute, ...))
	local success = results[1]
	if success then
		log.i("execute <-", inspect(results))
		return table.unpack(results, 2)
	else
		log.e("execute <-", inspect(results))
		return nil, results[2]
	end
end

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

local focusKitty = appSwitcher({
	bundleID = "net.kovidgoyal.kitty",
	name = "Kitty",
})
local aerospaceReloadConfig = function()
	log.i("Reloading AeroSpace config")
	local _, ok = hs.execute("aerospace reload-config --dry-run", true)
	if ok then
		_, ok = execute("aerospace reload-config", true)
		if ok then
			alert("✅ aerospace reload-config")
		end
	end
end
local aerospaceEnableToggle = function()
	hs.execute("aerospace enable toggle", true)
	alert("✅ aerospace enable toggle")
end

local modes = {}
modes.main = hotkey.modal.new(HYPER, "k")
modes.main:bind(HYPER, "space", focusKitty)
modes.main:bind(HYPER, "return", appSwitcher({ name = "Google Chrome" }))
modes.main:bind(HYPER, "a", appSwitcher({ bundleID = "com.fastmail.mac.Fastmail", name = "Fastmail" }))
modes.main:bind(HYPER, "d", hs.toggleConsole)
modes.main:bind(HYPER, "e", appSwitcher({ name = "Emacs" }))
modes.main:bind(HYPER, "i", appSwitcher({ name = "Linear" }))
modes.main:bind(HYPER, "k", function()
	modes.main:exit()
end)
modes.main:bind(HYPER, "l", hs.caffeinate.lockScreen)
modes.main:bind(HYPER, "m", appSwitcher({ bundleID = "com.apple.MobileSMS", name = "Messages" }))
modes.main:bind(HYPER, "o", appSwitcher({ name = "Finder" }))
modes.main:bind(HYPER, "p", appSwitcher({ name = "Claude" }))
-- modes.main:bind(HYPER, "t", appSwitcher({ name = "TickTick" })) -- hs.urlevent.openURL("ticktick://v1/show?today=today")
modes.main:bind(HYPER, "5", hs.reload)
modes.main:bind(HYPER, "6", aerospaceReloadConfig)
modes.main:bind(HYPER, "7", aerospaceEnableToggle)
-- modes.main:bind(HYPER, "f8", partial(hs.execute, "kitty -- emacs -nw --eval '(elfeed)'", true))
modes.main:bind(HYPER, "s", appSwitcher({ name = "Slack" }))
modes.main:bind(HYPER, "x", closeNotifications)
modes.main:enter()
modes.main.entered = partial(alert, "+main")
modes.main.exited = partial(alert, "-main")

---------------------------------------------------------------------------------------------------
-- Handle alt+return to focus terminal, but pass-through if already focused

-- local frontmostApplication = application.frontmostApplication

-- local frontmostBundleID = function()
--   local app = frontmostApplication()
--   return app and app:bundleID()
-- end
-- local isKittyFocused = function() return frontmostBundleID() == "net.kovidgoyal.kitty" end

-- local KC_RET = keycodes.map["return"]

-- local keydown = eventtap.new({ eventtap.event.types.keyDown }, function(e)
--   local keyCode = e:getKeyCode()
--   local flags = e:getFlags()
--   if flags.alt and not flags.shift and keyCode == KC_RET then
--     if not isKittyFocused() then
--       focusKitty()
--     else
--       eventtap.keyStroke(flags, keyCode)
--     end
--   end
-- end)

-- keydown:start()

alert("✅ Hammerspoon")
