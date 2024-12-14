-- local hs = require("hs")

local log = hs.logger.new("init", "debug")

local function bind_application(mods, key, app)
  local fn
  if type(app) == "string" then
    fn = function()
      log.d("launchorFocus", app)
      hs.application.launchOrFocus(app)
    end
  elseif type(app) == "table" then
    assert(#app == 1 and app.name or app.id)
    if app.name then
      fn = function()
        log.d("launchorFocus", app.name)
        hs.application.launchOrFocus(app.name)
      end
    else
      fn = function()
        log.d("launchOrFocusByBundleID", app.id)
        hs.application.launchOrFocusByBundleID(app.id)
      end
    end
  else
    error("application should be string or table with name or id attribute")
  end
  if type(mods) == "string" then
    mods = { mods }
  end
  assert(type(key) == "string")
  hs.hotkey.bind(mods, key, fn)
end
-- bind_application({ "alt" }, "return", "WezTerm")
--
hs.hotkey.bind({ "alt" }, "return", function()
  wez = hs.application.find("Wezterm")
  log.d(wez)
  if wez then
    if wez:isFrontmost() then
      wez:hide()
      -- hs.window.switcher.previousWindow()
    else
      wez:activate()
    end
  end
end)

hs.hotkey.bind({ "alt", "ctrl" }, "r", function()
  hs.reload()
  -- hs.alert.show("hammerspoon: config reloaded")
end)
