local wezterm = require("wezterm")

local log = require("dotfiles.util.logger").new("dotfiles.event.mux-startup")

---@class CommandPaletteEntry
---@field brief string
---@field action string
---@field doc string?
---@field icon string?

---@class dotfiles.command-palette
local M = {}

---@type CommandPaletteEntry[]
M.entries = {
  {
    brief = "Window | Workspace: Rename workspace",
    doc = "Prompts for new name for active workspace",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        wezterm.action.PromptInputLine({
          description = "Workspace name",
          initial_value = window:mux_window():get_workspace(),
          action = wezterm.action_callback(function(window, _, input)
            if input then
              window:mux_window():set_workspace(input)
            end
          end),
        }),
        pane
      )
    end),
  },
  {
    brief = "Window | Tab: Rename tab",
    doc = "Prompts for new title for active tab",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        wezterm.action.PromptInputLine({
          description = "Tab title",
          initial_value = window:active_tab():get_title(),
          action = wezterm.action_callback(function(window, _, input)
            if input then
              window:active_tab():set_title(input)
            end
          end),
        }),
        pane
      )
    end),
  },
  {
    brief = "WezTerm: Update all plugins",
    doc = "Pulls upstream changes for installed WezTerm plugins",
    action = wezterm.action_callback(wezterm.plugin.update_all),
  },
}

---@return dotfiles.command-palette
function M.add_entries(entries)
  for _, entry in ipairs(entries) do
    assert(entry.brief, "entry must have a brief")
    assert(entry.action, "entry must have an action")
    table.insert(M.entries, entry)
  end
  return M
end

wezterm.on("augment-command-palette", function()
  local entries = M.entries
  log:info("Adding " .. #entries .. " command palette entries")
  return entries
end)

function M.apply_to_config(config)
  return config
end

return M
