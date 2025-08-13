pcall(require, "hs.ipc")

local hs = _G["hs"]

local log = hs.logger.new("init.lua", "info")

local partial = hs.fnutils.partial

local config_watcher
config_watcher = hs.pathwatcher
	.new(hs.configdir .. "/init.lua", function(paths, flagTables)
		if config_watcher then
			hs.reload()
		end
	end)
	:start()

pcall(function()
	local fs = hs.fs
	local configdir = fs.pathToAbsolute(hs.configdir)
	local initdir = fs.pathToAbsolute(configdir .. "/init.lua"):match("(.*/)")
	if configdir ~= initdir then
		package.path = initdir .. "/?.lua;" .. package.path
		log.i("Added", initdir, "to package.path")
	end
end)

local menubar = hs.menubar.new(true, "usr")

local refreshMenubar = function()
	local stdout, ok = hs.execute(os.getenv("HOME") .. "/.dotfiles/bin/aws-sso-timeout")
	if ok then
		local title = ""
		local seconds = tonumber(stdout)
		local hours = seconds // 3600
		if hours > 0 then
			title = hours .. "h "
		end
		local minutes = math.fmod(seconds, 3600) // 60
		if minutes > 0 then
			title = title .. minutes .. "m"
		end
		menubar:setTitle(title)
	end
end

hs.timer.doEvery(60, refreshMenubar):start()

refreshMenubar()

-- Keybindings
local CTRL = "⌃"

local ALT = "⌥"

local SHIFT = "⇧"

local GUI = "⌘"

local MEH = CTRL .. SHIFT .. ALT

local HYPER = CTRL .. SHIFT .. ALT .. GUI

local executeFn = partial(partial, hs.execute)

local launchOrFocus = hs.application.launchOrFocus

local launchOrFocusFn = partial(partial, launchOrFocus)

local launchOrFocusWezTerm = function()
	return launchOrFocus("com.github.wez.wezterm") -- compiled from source
		or launchOrFocus("WezTerm") -- signed release
end

local closeNotifications = function()
	log.i("Closing notifications")
	hs.osascript.javascript([===[
    function run() {
      const SystemEvents = Application("System Events");

      const NotificationCenter =
        SystemEvents.processes.byName("NotificationCenter");

      const isPreSequoia = (() => {
        const app = Application.currentApplication();
        app.includeStandardAdditions = true;
        const { systemVersion } = app.systemInfo();
        return parseFloat(systemVersion) < 15.0;
      })();

      const windows = NotificationCenter.windows;
      if (windows.length === 0) {
        return;
      }

      (isPreSequoia
        ? windows.at(0).groups.at(0).scrollAreas.at(0).uiElements.at(0).groups()
        : windows // "Clear all" hierarchy
            .at(0)
            .groups.at(0)
            .groups.at(0)
            .scrollAreas.at(0)
            .groups()
            .at(0)
            .uiElements()
            .concat(
              windows // "Close" hierarchy
                .at(0)
                .groups.at(0)
                .groups.at(0)
                .scrollAreas.at(0)
                .groups(),
            )
      ).forEach((group) => {
        const [closeAllAction, closeAction] = group.actions().reduce(
          (matches, action) => {
            switch (action.description()) {
              case "Clear All":
                return [action, matches[1]];
              case "Close":
                return [matches[0], action];
              default:
                return matches;
            }
          },
          [null, null],
        );
        (closeAllAction ?? closeAction)?.perform();
      });
    }
]===])
end

local modes = setmetatable({}, {
	__newindex = function(self, name, mode)
		log.i("Registering mode", name)
		mode.entered = mode.entered or partial(hs.alert, "+" .. name)
		mode.exited = mode.exited or partial(hs.alert, "-" .. name)
		rawset(self, name, mode)
	end,
})

modes.main = hs.hotkey.modal
	.new(HYPER, "k")
	:bind(ALT, "return", launchOrFocusWezTerm)
	:bind(SHIFT .. ALT, "return", launchOrFocusFn("Google Chrome"))
	:bind(ALT, "e", launchOrFocusFn("Emacs"))
	:bind(ALT, "i", launchOrFocusFn("Linear"))
	:bind(ALT, "m", launchOrFocusFn("Messages"))
	:bind(ALT, "o", launchOrFocusFn("Finder"))
	:bind(ALT, "p", launchOrFocusFn("Claude"))
	:bind(ALT, "s", launchOrFocusFn("Slack"))
	:bind(HYPER, "a", executeFn("zsh -lc 'aerospace reload-config'"))
	:bind(HYPER, "d", hs.toggleConsole)
	:bind(HYPER, "l", hs.caffeinate.lockScreen)
	:bind(HYPER, "r", hs.reload)
	:bind(HYPER, "s", hs.hints.windowHints)
	:bind(HYPER, "x", closeNotifications)
	:bind(HYPER, "F1", function()
		hs.execute("zsh -lc 'wezterm cli spawn --new-window e1s'")
	end)
	:bind(HYPER, "F2", function()
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
	:bind(HYPER, "k", function() -- toggles mode
		modes.main:exit()
	end)
	:enter()

--- }}

hs.alert("✅ Hammerspoon")
