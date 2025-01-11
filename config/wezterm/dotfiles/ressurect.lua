local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local shell_quote = wezterm.shell_quote_arg
local util = require("dotfiles.util")

local M = {}

M.options = {}
M.options.age_op_executable = "age-op"
M.options.age_key_ref = "op://Private/c7jmto23pgqipx7xfjza26zdg4/password"

M.apply_to_config = function(config)
  local opts = M.options

  resurrect.set_encryption({
    enable = true,
    encrypt = function(file_path, lines)
      local command_string = string.format(
        [[%s -e -k %s -o]],
        shell_quote(opts.age_op_executable),
        shell_quote(opts.age_key_ref),
        shell_quote(file_path)
      )
      local success, output = util.exec_with_stdin(command_string, lines)
      wezterm.log_info(command_string, success, output)
      if not success then
        error("Encryption failed:" .. output)
      end
    end,
    decrypt = function(file_path)
      local command_list = string.format(
        [[%s -d -k %s %s]],
        shell_quote(opts.age_op_executable),
        shell_quote(opts.age_key_ref),
        shell_quote(file_path)
      )
      local success, stdout, stderr = wezterm.run_child_process(command_list)
      wezterm.log_info(command_list, success, stdout, stderr)
      if not success then
        error("Decryption failed: " .. stderr)
      end
      return stdout
    end,
  })

  require("dotfiles.keys").configure_keys(config, {
    {
      "LEADER",
      "w",
      wezterm.action_callback(function(win, pane)
        resurrect.save_state(resurrect.workspace_state.get_workspace_state())
      end),
    },
    {
      "LEADER",
      "W",
      resurrect.window_state.save_window_action(),
    },
    {
      key = "S",
      mods = "LEADER",
      action = resurrect.tab_state.save_tab_action(),
    },
    {
      key = "s",
      mods = "LEADER",
      action = wezterm.action_callback(function(win, pane)
        resurrect.save_state(resurrect.workspace_state.get_workspace_state())
        resurrect.window_state.save_window_action()
      end),
    },
  })
end

return M
