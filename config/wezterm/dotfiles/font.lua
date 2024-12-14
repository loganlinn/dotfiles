local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  local family = "Victor Mono"

  local harfbuzz_features = {
    "ss02", -- Slashed zero, variant 1
    "ss07", -- Straighter 6 and 9
  }

  config.font = wezterm.font({
    family = family,
    style = "Normal",
    harfbuzz_features = harfbuzz_features,
  })

  config.font_rules = {}
  for intensity, weight in pairs({ Normal = "Regular", Bold = "DemiBold", Half = "ExtraLight" }) do
    table.insert(config.font_rules, {
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

  config.font_size = 14

  config.cell_width = 1

  config.line_height = 1.1

  config.command_palette_font_size = config.font_size

  config.char_select_font_size = config.font_size

  return config
end

return M
