local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  local family = "Victor Mono"
  local harfbuzz_features = {
    "ss02", -- Slashed zero, variant 1
    "ss07", -- Straighter 6 and 9
  }

  local font = wezterm.font({
    family = family,
    style = "Normal",
    harfbuzz_features = harfbuzz_features,
  })

  local font_rules = {}
  for intensity, weight in pairs({ Normal = "Regular", Bold = "DemiBold", Half = "ExtraLight" }) do
    table.insert(font_rules, {
      italic = true,
      intensity = intensity,
      font = wezterm.font({
        family = family,
        style = "Oblique",
        weight = weight,
        harfbuzz_features = harfbuzz_features,
      }),
    })
  end

  local font_size = 14

  config.font = font
  config.font_rules = font_rules
  config.font_size = font_size
  config.cell_width = 1
  config.line_height = 1.1
  config.char_select_font_size = font_size
  config.window_frame = config.window_frame or {}
  config.window_frame.font = font
  config.window_frame.font_size = font_size
  config.command_palette_font_size = font_size
  config.warn_about_missing_glyphs = false

  return config
end

return M
