local wezterm = require("wezterm")
local act = require("dotfiles.action")
local log = require("dotfiles.util.logger").new("dotfiles.keys")

local M = {}

---@return Key
function M.Key(mods, key, action)
  assert(type(key) == "string")
  return {
    key = key,
    mods = mods or "NONE",
    action = action,
  }
end

---@param config Config
---@param name? string
---@return Key[]
function M.get_keys(config, name)
  if name == nil then
    config.keys = config.keys or {}
    return config.keys
  end
  config.key_tables = config.key_tables or {}
  config.key_tables[name] = config.key_tables[name] or {}
  return config.key_tables[name]
end

---@param keys Key[]
---@param ... Key|[string, string, KeyAssignment]
---@return Key[]
function M.insert_keys(keys, ...)
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    if arg[2] and arg[3] then
      table.insert(keys, M.Key(arg[1], arg[2], arg[3]))
    else
      table.insert(keys, arg)
    end
  end
  return keys
end

---@param config Config
---@return Config
function M.apply_to_config(config)
  local SUPER = [[SUPER]]
  local LEADER = [[LEADER]]
  local MOD = [[CTRL|SHIFT]]

  config.disable_default_key_bindings = true
  config.enable_kitty_keyboard = true
  config.enable_csi_u_key_encoding = false

  config.leader = { mods = MOD, key = "Space", timeout_milliseconds = math.maxinteger }

  M.insert_keys(
    M.get_keys(config),
    --[[ Pane ]]
    M.Key(MOD, "H", act.activate_direction("Left")),
    M.Key(MOD, "J", act.activate_direction("Down")),
    M.Key(MOD, "K", act.activate_direction("Up")),
    M.Key(MOD, "L", act.activate_direction("Right")),
    --
    M.Key(MOD, "DownArrow", wezterm.action.AdjustPaneSize({ "Down", 15 })),
    M.Key(MOD, "LeftArrow", wezterm.action.AdjustPaneSize({ "Left", 15 })),
    M.Key(MOD, "RightArrow", wezterm.action.AdjustPaneSize({ "Right", 15 })),
    M.Key(MOD, "UpArrow", wezterm.action.AdjustPaneSize({ "Up", 15 })),
    --
    M.Key(MOD, "W", wezterm.action.CloseCurrentPane({ confirm = true })),
    M.Key(SUPER, "w", wezterm.action.CloseCurrentPane({ confirm = false })),
    --
    M.Key(MOD, "Enter", act.split_pane()),
    M.Key(MOD, "~", act.toggle_popup_pane),
    --
    M.Key(MOD, "R", wezterm.action.RotatePanes("CounterClockwise")),
    M.Key(MOD, "S", wezterm.action.PaneSelect({ mode = "SwapWithActive" })),
    M.Key(MOD, "Z", wezterm.action.TogglePaneZoomState),
    M.Key("LEADER|SHIFT", "T", act.move_pane_to_new_tab({ activate = true })),
    M.Key(MOD, "B", wezterm.action.PaneSelect({ mode = "MoveToNewWindow" })),
    --[[ Tab ]]
    M.Key(SUPER, "1", wezterm.action.ActivateTab(0)),
    M.Key(SUPER, "2", wezterm.action.ActivateTab(1)),
    M.Key(SUPER, "3", wezterm.action.ActivateTab(2)),
    M.Key(SUPER, "4", wezterm.action.ActivateTab(3)),
    M.Key(SUPER, "5", wezterm.action.ActivateTab(4)),
    M.Key(SUPER, "6", wezterm.action.ActivateTab(5)),
    M.Key(SUPER, "7", wezterm.action.ActivateTab(6)),
    M.Key(SUPER, "8", wezterm.action.ActivateTab(7)),
    M.Key(SUPER, "9", wezterm.action.ActivateTab(8)),
    --
    M.Key(MOD, "T", wezterm.action.SpawnTab("CurrentPaneDomain")),
    --
    M.Key(MOD, "<", wezterm.action.MoveTabRelative(-1)),
    M.Key(MOD, ">", wezterm.action.MoveTabRelative(1)),
    --
    M.Key(MOD, "{", wezterm.action.ActivateTabRelative(-1)),
    M.Key(MOD, "}", wezterm.action.ActivateTabRelative(1)),
    --
    M.Key("CTRL", "Tab", wezterm.action.ActivateTabRelative(1)),
    M.Key("CTRL|SHIFT", "Tab", wezterm.action.ActivateTabRelative(-1)),
    --[[ Window ]]
    M.Key(SUPER, "n", wezterm.action.SpawnWindow),
    M.Key(SUPER, "PageDown", wezterm.action.ToggleAlwaysOnBottom),
    M.Key(SUPER, "PageUp", wezterm.action.ToggleAlwaysOnTop),
    -- Workspace
    M.Key(MOD, "9", wezterm.action.SwitchWorkspaceRelative(-1)),
    M.Key(MOD, "0", wezterm.action.SwitchWorkspaceRelative(1)),
    M.Key(LEADER, "Space", wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" })),
    M.Key(LEADER, ".", act.RenameWorkspace),
    --
    M.Key(
      LEADER,
      "p",
      wezterm.action_callback(function(window, pane)
        -- TODO generate, cache complete list
        local workspaces = {
          {
            id = wezterm.home_dir .. "/.dotfiles",
            label = "loganlinn/dotfiles",
          },
          {
            id = wezterm.home_dir .. "/src/github.com/gamma-app/gamma",
            label = "gamma-app/gamma",
          },
        }

        window:perform_action(
          wezterm.action.InputSelector({
            title = "Switch to workspace",
            choices = workspaces,
            fuzzy = true,
            action = wezterm.action_callback(function(inner_window, inner_pane, choice_id, choice_label)
              if not choice_id and not choice_label then
                log.info("input selector cancelled")
                return
              end
              inner_window:perform_action(wezterm.action.SwitchToWorkspace({
                name = choice_label,
                spawn = {
                  label = "Workspace: " .. choice_label,
                  cwd = choice_id,
                },
              }, inner_pane))
            end),
          }),
          pane
        )
      end)
    ),

    --[[ Output ]]
    M.Key(MOD, "c", wezterm.action.CopyTo("Clipboard")),
    M.Key(MOD, "v", wezterm.action.PasteFrom("Clipboard")),
    M.Key(LEADER, "v", wezterm.action.ActivateCopyMode),
    --
    M.Key(SUPER, "f", wezterm.action.Search({ CaseSensitiveString = "" })),
    M.Key(MOD, "F", wezterm.action.QuickSelect),
    M.Key(MOD, "E", act.quick_open), -- https://loganlinn.com
    M.Key(MOD, "o", wezterm.action.ActivateKeyTable({ name = "Open" })), -- https://loganlinn.com
    --
    M.Key(MOD, "Home", wezterm.action.ScrollToTop),
    M.Key(MOD, "PageDown", wezterm.action.ScrollToPrompt(1)),
    M.Key(MOD, "PageUp", wezterm.action.ScrollToPrompt(0)),
    M.Key(MOD, "End", wezterm.action.ScrollToBottom),
    --
    M.Key(SUPER, "0", wezterm.action.ResetFontSize),
    M.Key(SUPER, "-", wezterm.action.DecreaseFontSize),
    M.Key(SUPER, "=", wezterm.action.IncreaseFontSize),
    M.Key(SUPER, "DownArrow", wezterm.action.AdjustPaneSize({ "Down", 15 })),
    M.Key(SUPER, "UpArrow", wezterm.action.AdjustPaneSize({ "Up", 15 })),
    --
    M.Key(SUPER, "Home", wezterm.action.ScrollToTop),
    M.Key(SUPER, "PageDown", wezterm.action.ScrollByPage(1)),
    M.Key(SUPER, "PageUp", wezterm.action.ScrollByPage(-1)),
    M.Key(SUPER, "End", wezterm.action.ScrollToBottom),
    M.Key(SUPER, "UpArrow", wezterm.action.ScrollToPrompt(-1)),
    M.Key(SUPER, "DownArrow", wezterm.action.ScrollToPrompt(1)),

    --[[ Application ]]
    M.Key(LEADER, "q", wezterm.action.QuitApplication),
    M.Key(MOD, "p", wezterm.action.ActivateCommandPalette),
    --
    --[[ Auxilary ]]
    M.Key(SUPER, "F1", wezterm.action.ShowDebugOverlay),
    M.Key(SUPER, "F2", act.RenameTab),
    M.Key(SUPER, "F5", wezterm.action.ReloadConfiguration),
    M.Key(SUPER, "F6", act.debug_window),
    M.Key(SUPER, "F7", act.debug_pane),
    M.Key(SUPER, "F8", act.toggle_debug_key_events),

    --[[ Keys ]]
    M.Key(MOD, [[|]], wezterm.action.ActivateKeyTable({ name = "Split" })),
    M.Key(LEADER, "i", wezterm.action.ActivateKeyTable({ name = "Insert" }))
    -- M.Key(LEADER, "t", wezterm.action.ActivateKeyTable({ name = "Toggle" })),
    -- M.Key(LEADER, "w", wezterm.action.ActivateKeyTable({ name = "Window" }))
  )

  M.insert_keys(
    M.get_keys(config, "Insert"),
    M.Key(nil, "u", wezterm.action.CharSelect),
    M.Key(nil, "p", wezterm.action.PasteFrom("Clipboard")),
    M.Key("SHIFT", "P", wezterm.action.PasteFrom("PrimarySelection"))
  )

  M.insert_keys(
    M.get_keys(config, "Split"),
    M.Key(nil, "h", wezterm.action.SplitPane({ top_level = true, direction = "Left" })),
    M.Key(nil, "j", wezterm.action.SplitPane({ top_level = true, direction = "Down" })),
    M.Key(nil, "k", wezterm.action.SplitPane({ top_level = true, direction = "Up" })),
    M.Key(nil, "l", wezterm.action.SplitPane({ top_level = true, direction = "Right" })),
    M.Key("SHIFT", "H", wezterm.action.SplitPane({ direction = "Up" })),
    M.Key("SHIFT", "J", wezterm.action.SplitPane({ direction = "Right" })),
    M.Key("SHIFT", "K", wezterm.action.SplitPane({ direction = "Left" })),
    M.Key("SHIFT", "L", wezterm.action.SplitPane({ direction = "Down" }))
  )

  -- Mouse bindings
  config.mouse_bindings = config.mouse_bindings or {}
  table.insert(config.mouse_bindings, {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "SUPER",
    action = wezterm.action.OpenLinkAtMouseCursor,
  })
  table.insert(config.mouse_bindings, {
    event = { Up = { streak = 1, button = "Middle" } },
    mods = "NONE",
    action = wezterm.action.OpenLinkAtMouseCursor,
  })

  return config
end

return M
