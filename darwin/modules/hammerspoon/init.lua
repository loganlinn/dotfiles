local homedir = os.getenv("HOME")
package.path = package.path .. ";" .. homedir .. "/.dotfiles/darwin/modules/hammerspoon/?.lua"
package.path = package.path .. ";" .. homedir .. "/.dotfiles/darwin/modules/hammerspoon/?/init.lua"
package.cpath = package.cpath .. ";" .. homedir .. "/.dotfiles/darwin/modules/hammerspoon/?.so"
package.path = package.path
  .. ";"
  .. homedir
  .. "/.luarocks/share/lua/5.4/?.lua;"
  .. homedir
  .. "/.luarocks/share/lua/5.4/?/init.lua"
package.cpath = package.cpath .. ";" .. homedir .. "/.luarocks/lib/lua/5.4/?.so"
package.path = package.path
  .. ";"
  .. homedir
  .. "/.luarocks/share/lua/5.3/?.lua;"
  .. homedir
  .. "/.luarocks/share/lua/5.3/?/init.lua"
package.cpath = package.cpath .. ";" .. homedir .. "/.luarocks/lib/lua/5.3/?.so"

local fennel = require("fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)

hs.ipc.cliInstall()

hs.hints.style = "vimperator"
hs.hints.showTitleThresh = 4
hs.hints.titleMaxSize = 10
hs.hints.fontSize = 30
hs.window.animationDuration = 0.2

local log = hs.logger.new("init.lua", "debug")

local config_watcher
config_watcher = hs.pathwatcher
  .new(hs.configdir .. "/init.lua", function()
    if config_watcher then
      hs.reload()
    end
  end)
  :start()

local aws_menubar = hs.menubar.new(true, "aws"):setClickCallback(function(mods)
  log.i("menubar clicked", hs.inspect(mods))
end)

hs.timer
  .doEvery(60, function()
    local title = "aws"
    local stdout, ok = hs.execute(homedir .. "/.dotfiles/bin/aws-sso-timeout")
    if ok then
      local seconds = tonumber(stdout)
      if seconds then
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor(math.fmod(seconds, 3600) / 60)
        title = title .. string.format("[%02d:%02d]", hours, minutes)
      end
    end
    aws_menubar:setTitle(title)
  end)
  :start()
  :fire()

-- Keybindings
local CTRL = "⌃"
local ALT = "⌥"
local SHIFT = "⇧"
local GUI = "⌘"
local MEH = CTRL .. SHIFT .. ALT
local HYPER = CTRL .. SHIFT .. ALT .. GUI

local partial = hs.fnutils.partial
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
    hs.alert("F2")
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

-- hs.loadSpoon("EmmyLua")
hs.alert("✅ Hammerspoon")
