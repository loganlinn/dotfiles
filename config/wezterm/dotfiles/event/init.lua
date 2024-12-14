return {
  register = function()
    local wezterm = require("wezterm")
    for _, event in ipairs({
      "user-var-changed",
      "open-uri",
      "format-window-title",
    }) do
      wezterm.on(event, require("dotfiles.event." .. event))
    end
  end,
}
