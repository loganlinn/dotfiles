local wezterm = require("wezterm")

local M = {}

-- Helper function to create a formatted choice label
local function format_script_label(name, script)
  return wezterm.format({
    { Foreground = { Color = "#89B4FA" } }, -- Bright color for name
    { Text = name },
    { Foreground = { Color = "#666666" } }, -- Dim color for script
    { Text = " → " .. script },
  })
end

local shell_command = function(command)
  if type(command) ~= "string" then
    command = wezterm.shell_join_args(command)
  end
  return {
    "/usr/bin/env",
    "zsh",
    "-c",
    command,
  }
end

-- Function to get yarn scripts from package.json
local function generate_choices(cwd)
  local success, stdout, stderr =
    wezterm.run_child_process(shell_command("cd " .. wezterm.shell_quote_arg(cwd) .. " && yarn run --json"))

  if not success then
    wezterm.log_error("Failed to get yarn scripts: " .. (stderr or ""))
    return {}
  end

  local choices = {}

  for line in stdout:gmatch("[^\r\n]+") do
    local success, json = pcall(wezterm.json_parse, line)
    if success and json.name and json.script then
      table.insert(choices, {
        id = json.name,
        label = format_script_label(json.name, json.script),
      })
    end
  end

  return choices
end
M.generate_choices = generate_choices

-- Action that shows the InputSelector
M.input_selector = wezterm.action_callback(function(window, pane)
  local pane = pane or window:active_tab():active_pane()
  local cwd = (pane:get_current_working_dir() or {}).file_path
  if not cwd then
    wezterm.log_warn("No current working directory", pane)
    return
  end

  local choices = generate_choices(cwd)

  if #choices == 0 then
    wezterm.log_error("No yarn scripts found in the current directory")
    return
  end

  window:perform_action(
    wezterm.action.InputSelector({
      title = "Select Yarn Script",
      choices = choices,
      action = wezterm.action_callback(function(window, pane, id, label)
        wezterm.log_info("selection", id, label)
        if not id then
          return
        end

        pane:split({
          cwd = cwd,
          args = shell_command({ "yarn", "run", id }),
        })
        -- local action = wezterm.action.SpawnCommandInNewTab({
        --   args = shell_command("cd " .. wezterm.shell_quote_arg(cwd) .. " && yarn run " .. wezterm.shell_quote_arg(id)),
        -- })
        -- wezterm.log_info("action", action)

        -- window:perform_action(action, pane)
      end),
    }),
    pane
  )
end)

return M
