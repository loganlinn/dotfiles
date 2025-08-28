local wezterm = require("wezterm")

return {
  apply_to_config = function(config)
    config.unix_domains = {
      { name = "unix" },
    }

    config.wsl_domains = config.wsl_domains or wezterm.default_wsl_domains()

    config.mux_enable_ssh_agent = true

    config.ssh_domains = {}

    for name, ssh_host in pairs(wezterm.enumerate_ssh_hosts()) do
      -- ssh_host: user, hostname, port, identityagent, identityfile, sendenv, userknownhostsfile
      table.insert(config.ssh_domains, {
        name = name,
        remote_address = ssh_host.hostname,
        multiplexing = "None",
        assume_shell = "Posix",
      })
    end

    config.mux_env_remove = {
      "SSH_AUTH_SOCK",
      "SSH_CLIENT",
      "SSH_CONNECTION",
    }

    -- config.default_gui_startup_args = { 'connect', 'unix' }

    return config
  end,
}
