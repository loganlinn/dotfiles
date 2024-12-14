local wezterm = require("wezterm")

---@param window Window
---@param pane Pane
---@param name string
---@param value string
return function(window, pane, name, value)
  wezterm.log_info("event:user-var-changed", name, value)
  -- zen-mode.nvim integration
  -- https://github.com/folke/zen-mode.nvim/blob/29b292bdc58b76a6c8f294c961a8bf92c5a6ebd6/README.md#wezterm
  if "ZEN_MODE" == name then
    local overrides = window:get_config_overrides() or {}
    local n = tonumber(value)
    if type(n) == "number" then
      -- incremental
      if value:find("+") ~= nil then
        while n > 0 do
          window:perform_action(wezterm.action.IncreaseFontSize, pane)
          n = n - 1
        end
        overrides.enable_tab_bar = false
      elseif n < 0 then
        window:perform_action(wezterm.action.ResetFontSize, pane)
        overrides.font_size = nil
        overrides.enable_tab_bar = true
      else
        overrides.font_size = n --[[@as number]]
        overrides.enable_tab_bar = false
      end
    else
      wezterm.log_warn("expected number value for user-var ZEN_MODE")
    end
    window:set_config_overrides(overrides)
  end
end
