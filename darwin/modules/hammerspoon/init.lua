local log = hs.logger.new("init.lua", "info")

log.i("Initializing...", hs.inspect(hs.processInfo))

-- Enable Hammerspoon IPC
pcall(require, "hs.ipc")

-- Setup package.path
pcall(function()
  -- if ~/.hammerspoon/init.lua is symlinked, add the source parent to package.path
  local fs = hs.fs
  local configdir = fs.pathToAbsolute(hs.configdir)
  local initdir = fs.pathToAbsolute(configdir .. "/init.lua"):match("(.*/)")
  if configdir ~= initdir then
    package.path = initdir .. "/?.lua;" .. package.path
    log.i("Added", initdir, "to package.path")
  end
end)

--- Helpers
local partial = function(f, ...)
  local wrap = function(f, x)
    return function(...)
      return f(x, ...)
    end
  end
  for i = 1, select("#", ...) do
    f = wrap(f, select(i, ...))
  end
  return f
end

-- Keybindings
local CTRL = "⌃"
local ALT = "⌥"
local SHIFT = "⇧"
local GUI = "⌘"
local MEH = CTRL .. SHIFT .. ALT
local HYPER = CTRL .. SHIFT .. ALT .. GUI

local launchOrFocusFn = partial(partial, hs.application.launchOrFocus)

local weztermActivate = function()
  return hs.application.launchOrFocus("com.github.wez.wezterm") -- compiled from source
    or hs.application.launchOrFocus("WezTerm") -- signed release
end

local aerospaceReload = function()
  hs.execute("aerospace reload-config", true)
  hs.alert("✅ Aerospace")
end

local lockScreen = function()
  hs.caffeinate.lockScreen()
end

closeNotifications = function()
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

local modes = {}
modes.main = hs.hotkey.modal
  .new(HYPER, "k")
  :bind(ALT, "return", weztermActivate)
  :bind(SHIFT .. ALT, "return", launchOrFocusFn("Google Chrome"))
  :bind(ALT, "e", launchOrFocusFn("Emacs"))
  :bind(ALT, "i", launchOrFocusFn("Linear"))
  :bind(ALT, "m", launchOrFocusFn("Messages"))
  :bind(ALT, "o", launchOrFocusFn("Finder"))
  :bind(ALT, "p", launchOrFocusFn("Claude"))
  :bind(ALT, "s", launchOrFocusFn("Slack"))
  :bind(HYPER, "a", aerospaceReload)
  :bind(HYPER, "d", hs.toggleConsole)
  :bind(HYPER, "l", lockScreen)
  :bind(HYPER, "r", hs.reload)
  :bind(HYPER, "b", closeNotifications)
  :bind(HYPER, "s", function()
    -- hs.hints.style = "vimperator"
    hs.hints.windowHints()
  end)
  :bind(HYPER, "k", function()
    modes.main:exit()
  end)
  :enter()
function modes.main:entered()
  hs.alert("+main")
end

function modes.main:exited()
  hs.alert("-main")
end

--- }}

-- automatic reload on config changes
local config_watcher
config_watcher = hs.pathwatcher
  .new(hs.configdir .. "/init.lua", function(paths, flagTables)
    log.i("Change detected", hs.inspect(paths), hs.inspect(flagTables))
    if config_watcher then
      hs.reload()
    end
  end)
  :start()

hs.shutdownCallback = function(...)
  log.i("Shutting down", ...)
end

hs.accessibilityState(true)
-- hs.allowAppleScript(true)
-- hs.autoLaunch(true)

hs.alert("✅ Hammerspoon")
