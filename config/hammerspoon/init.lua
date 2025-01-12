require("hs.ipc") -- enables `hc` CLI

local log = hs.logger.new("init", "debug")

hs.hotkey.bind({ "alt" }, "return", function()
  hs.application.launchOrFocus("Wezterm")
end)

hs.hotkey.bind({ "alt" }, "g", function()
  hs.application.launchOrFocus("Gemini")
end)

hs.hotkey.bind({ "alt", "ctrl" }, "r", function()
  hs.reload()
end)
