local wezterm = require("wezterm")

return {
  apply_to_config = function(config)
    config.unix_domains = {
      { name = "unix" },
    }

    config.wsl_domains = config.wsl_domains or wezterm.default_wsl_domains()

    config.mux_enable_ssh_agent = true

    config.mux_env_remove = {
      "SSH_AUTH_SOCK",
      "SSH_CLIENT",
      "SSH_CONNECTION",
    }

    -- config.default_gui_startup_args = { 'connect', 'unix' }

    return config
  end,
}
