local wezterm = require("wezterm")

local M = {}

M.docker_list = function()
  local containers = {}
  local success, stdout, stderr = wezterm.run_child_process({
    "docker",
    "container",
    "ls",
    "--format",
    "{{.ID}}:{{.Names}}",
  })
  for _, line in ipairs(wezterm.split_by_newlines(stdout)) do
    local id, name = line:match("(.-):(.+)")
    if id and name then
      containers[id] = name
    end
  end
  return containers
end

M.exec_domains = function(exec_domains)
  exec_domains = exec_domains or {}

  for id, name in pairs(M.docker_list()) do
    local label = function(name)
      local success, stdout, stderr = wezterm.run_child_process({
        "docker",
        "inspect",
        "--format",
        "{{.State.Running}}",
        id,
      })
      local running = stdout == "true\n"
      local color = running and "Green" or "Red"
      return wezterm.format({
        { Foreground = { AnsiColor = color } },
        { Text = "docker container named " .. name },
      })
    end

    local fixup = function(cmd)
      cmd.args = cmd.args or { "/bin/sh" }
      local wrapped = {
        "docker",
        "exec",
        "-it",
        id,
      }
      for _, arg in ipairs(cmd.args) do
        table.insert(wrapped, arg)
      end

      cmd.args = wrapped
      return cmd
    end

    table.insert(exec_domains, wezterm.exec_domain("docker:" .. name, fixup, label))
  end

  return exec_domains
end
