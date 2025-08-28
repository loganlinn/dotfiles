local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  -- Victor Mono
  -- * ss02 - Slashed zero, variant 1
  -- * ss07 - Straighter 6 and 9
  config.harfbuzz_features = { "ss02", "ss07" }
  config.font = wezterm.font_with_fallback({
    -- { family = "Pragmasevka Nerd Font" },
    {
      family = "Victor Mono",
      style = "Normal",
    },
  })
  config.font_rules = {
    {
      italic = true,
      intensity = "Normal",
      font = wezterm.font_with_fallback({
        -- { family = "Pragmasevka Nerd Font", weight = "Light", style = "Italic" },
        {
          family = "Victor Mono",
          style = "Oblique",
          weight = "Regular",
        },
      }),
    },
    {
      italic = true,
      intensity = "Bold",
      font = wezterm.font_with_fallback({
        -- { family = "Pragmasevka Nerd Font", weight = "Bold", style = "Italic" },
        {
          family = "Victor Mono",
          style = "Oblique",
          weight = "DemiBold",
        },
      }),
    },
    {
      italic = true,
      intensity = "Half",
      font = wezterm.font_with_fallback({
        -- { family = "Pragmasevka Nerd Font", weight = "Bold", style = "Normal" },
        {
          family = "Victor Mono",
          style = "Oblique",
          weight = "ExtraLight",
        },
      }),
    },
  }
  config.font_size = 14
  config.cell_width = 1
  -- config.line_height = 1
  config.char_select_font_size = 14
  config.window_frame = config.window_frame or {}
  config.window_frame.font = config.window_frame.font or config.font
  config.window_frame.font_size = 14
  config.command_palette_font_size = 14
  config.warn_about_missing_glyphs = false
  return config
end

return M
