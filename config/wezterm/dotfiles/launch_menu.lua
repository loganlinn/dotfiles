local wezterm = require("wezterm")

local run_child_process = function(args)
  wezterm.log_info("running", args)
  local success, stdout, stderr = wezterm.run_child_process(args)
  if not success then
    wezterm.log_error(wezterm.format({
      { Foreground = { Color = "Red" } },
      { Text = stderr },
      "ResetAttributes",
    }))
    return nil, stdout, stderr
  end
  return stdout
end
return {
  apply_to_config = function(config)
    local function shell_item(command, label)
      local command_string
      if type(command) == "string" then
        command_string = command
      else
        command_string = wezterm.shell_join_args(command)
      end
      label = label or command[1]
      return {
        label = wezterm.format({
          { Foreground = { AnsiColor = "Green" } },
          { Text = wezterm.pad_right(label or "", 32) },
          "ResetAttributes",
          { Foreground = { AnsiColor = "Grey" } },
          { Text = "# " .. command_string },
        }),
        args = {
          "zsh",
          "-lec",
          wezterm.shell_join_args({ "wezterm", "cli", "set-tab-title", label or command_string })
            .. ";"
            .. command_string,
        },
      }
    end

    config.launch_menu = {
      shell_item("just --justfile ~/.dotfiles/justfile switch", "switch"),
      shell_item("gh dash"),
      shell_item("clickhouse client --connection production"),
      shell_item("clickhouse client --connection staging"),
      shell_item("clickhouse client --connection production"),
    }

    return config
  end,
}
