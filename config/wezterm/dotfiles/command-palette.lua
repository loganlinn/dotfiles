---@class CommandPaletteEntry
---@field brief string
---@field action string
---@field doc string?
---@field icon string?

local wezterm = require("wezterm")
local act = wezterm.action

---@class dotfiles.command-palette
M = {}
M.enabled = false

---@type CommandPaletteEntry[]
M.entries = {
  {
    brief = "Rename tab",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      initial_value = "My Tab Name",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

---@param entries CommandPaletteEntry[]
M.add_entries = function(entries)
  for _, entry in ipairs(entries) do
    assert(entry.brief, "entry must have a brief")
    assert(entry.action, "entry must have an action")
    table.insert(M.entries, entry)
  end
end

function M.apply_to_config(config)
  wezterm.on("augment-command-palette", function()
    print("WHY1")
    return M.entries
  end)
  return config
end

return M
