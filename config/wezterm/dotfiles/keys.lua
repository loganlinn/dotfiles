local wezterm = require("wezterm")
local act = require("dotfiles.action")

local function assign(config, name, ...)
  if select("#", ...) == 0 then
    return
  end

  ---@type Key[]
  local keys
  if not name then
    config.keys = config.keys or {}
    keys = config.keys
  else
    if not config.key_tables[name] then
      config.key_tables[name] = {}
    end
    keys = config.key_tables[name]
  end
  -- expand and insert into key table
  for i = 1, select("#", ...) do
    ---@type [string, string, KeyAssignment]
    local spec = select(i, ...)
    local mods, key, action = spec[1], spec[2], spec[3]
    if key and action then
      table.insert(keys, {
        key = key,
        mods = mods or "NONE",
        action = action,
      })
    end
  end
end

---@param config Config
---@return Config
local function apply_to_config(config)
  local mod = "CTRL|SHIFT"
  local super = "SUPER"
  local leader = "LEADER"

  config.keys = config.keys or {}
  config.key_tables = config.key_tables or {}
  config.leader = { mods = mod, key = "Space", timeout_milliseconds = math.maxinteger }
  config.disable_default_key_bindings = true
  config.enable_kitty_keyboard = true
  config.enable_csi_u_key_encoding = false

  local function activate_key_table(name, ...)
    assert(config.key_tables[name] == nil)
    assign(config, name, ...)
    return act.ActivateKeyTable({ name = name })
  end

  assign(
    config,
    nil,
    --[[ Pane ]]
    { mod, "H", act.activate_direction("Left") },
    { mod, "J", act.activate_direction("Down") },
    { mod, "K", act.activate_direction("Up") },
    { mod, "L", act.activate_direction("Right") },

    { mod, "DownArrow", act.AdjustPaneSize({ "Down", 10 }) },
    { mod, "LeftArrow", act.AdjustPaneSize({ "Left", 10 }) },
    { mod, "RightArrow", act.AdjustPaneSize({ "Right", 10 }) },
    { mod, "UpArrow", act.AdjustPaneSize({ "Up", 10 }) },

    { mod, "W", act.CloseCurrentPane({ confirm = true }) },
    { super, "w", act.CloseCurrentPane({ confirm = false }) },

    { mod, "Enter", act.SplitPaneAuto() },
    { mod, "~", act.TogglePopupPane },

    { mod, "R", act.RotatePanes("CounterClockwise") },
    { mod, "S", act.PaneSelect({ mode = "SwapWithActive" }) },
    { mod, "Z", act.TogglePaneZoomState },

    { leader .. "|SHIFT", "T", act.MovePaneToNewTab({ activate = true }) },
    { mod, "B", act.PaneSelect({ mode = "MoveToNewWindow" }) },

    --[[ Tab ]]
    { super, "1", act.ActivateTab(0) },
    { super, "2", act.ActivateTab(1) },
    { super, "3", act.ActivateTab(2) },
    { super, "4", act.ActivateTab(3) },
    { super, "5", act.ActivateTab(4) },
    { super, "6", act.ActivateTab(5) },
    { super, "7", act.ActivateTab(6) },
    { super, "8", act.ActivateTab(7) },
    { super, "9", act.ActivateTab(8) },

    { mod, "T", act.SpawnTab("CurrentPaneDomain") },

    { mod, "<", act.MoveTabRelative(-1) },
    { mod, ">", act.MoveTabRelative(1) },

    { mod, "{", act.ActivateTabRelative(-1) },
    { mod, "}", act.ActivateTabRelative(1) },

    { "CTRL", "Tab", act.ActivateTabRelative(1) },
    { "CTRL|SHIFT", "Tab", act.ActivateTabRelative(-1) },

    --[[ Window ]]
    { super, "n", act.SpawnWindow },
    { super, "PageDown", wezterm.action.ToggleAlwaysOnBottom },
    { super, "PageUp", wezterm.action.ToggleAlwaysOnTop },

    -- Workspace
    { mod, "9", act.SwitchWorkspaceRelative(-1) },
    { mod, "0", act.SwitchWorkspaceRelative(1) },
    { leader, "Space", act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
    { leader, ".", act.RenameWorkspace },
    {
      leader,
      "p",
      act.SpawnCommandInNewWindow({
        args = {
          "zsh",
          "-c",
          'exec zshi "$@"',
          "-s",
          'zi && wezterm cli rename-workspace "${PWD:t2}"',
        },
      }),
    }, -- WIP

    --[[ Output ]]
    { mod, "c", act.CopyTo("Clipboard") },
    { mod, "v", act.PasteFrom("Clipboard") },

    { super, "f", act.Search({ CaseSensitiveString = "" }) },
    { mod, "F", act.QuickSelect },
    { mod, "E", act.QuickSelectUrl }, -- https://loganlinn.com
    { mod, "o", act.ActivateKeyTable({ name = "Open" }) }, -- https://loganlinn.com

    { super, "0", wezterm.action.ResetFontSize },
    { super, "-", wezterm.action.DecreaseFontSize },
    { super, "=", wezterm.action.IncreaseFontSize },

    { super, "Home", act.ScrollToTop },
    { super, "PageDown", act.ScrollByPage(1) },
    { super, "PageUp", act.ScrollByPage(-1) },
    { super, "End", act.ScrollToBottom },
    { super, "UpArrow", act.ScrollToPrompt(-1) },
    { super, "DownArrow", act.ScrollToPrompt(1) },

    --[[ Application ]]
    { leader, "q", act.QuitApplication },
    { leader, ":", act.ActivateCommandPalette },

    --[[ Auxilary ]]
    { super, "F1", act.ShowDebugOverlay },
    { super, "F2", act.RenameTab },
    { super, "F5", act.ReloadConfiguration },
    { super, "F6", act.DumpWindow },
    { super, "F7", act.DumpPane },
    { super, "F8", act.ToggleDebugKeyEvents },

    --[[ Keys ]]
    { mod, [[|]], act.ActivateKeyTable({ name = "Split" }) },
    { leader, "i", act.ActivateKeyTable({ name = "Insert" }) }
    -- { leader, "t", act.ActivateKeyTable({ name = "Toggle" }) },
    -- { leader, "w", act.ActivateKeyTable({ name = "Window" }) }
  )

  assign(
    config,
    "Insert",
    { nil, "u", act.CharSelect },
    { nil, "p", act.PasteFrom("Clipboard") },
    { "SHIFT", "P", act.PasteFrom("PrimarySelection") }
  )

  assign(
    config,
    "Split",
    { nil, "h", act.SplitPane({ top_level = true, direction = "Left" }) },
    { nil, "j", act.SplitPane({ top_level = true, direction = "Down" }) },
    { nil, "k", act.SplitPane({ top_level = true, direction = "Up" }) },
    { nil, "l", act.SplitPane({ top_level = true, direction = "Right" }) },
    { "SHIFT", "H", act.SplitPane({ direction = "Up" }) },
    { "SHIFT", "J", act.SplitPane({ direction = "Right" }) },
    { "SHIFT", "K", act.SplitPane({ direction = "Left" }) },
    { "SHIFT", "L", act.SplitPane({ direction = "Down" }) }
  )

  assign(config, "Open", { nil, "e", act.QuickEdit }, { nil, "u", act.QuickSelectUrl })

  return config
end

return {
  apply_to_config = apply_to_config,
}
