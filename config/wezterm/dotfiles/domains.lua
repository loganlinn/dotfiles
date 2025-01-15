local wezterm = require("wezterm")
return {
  apply_to_config = function(config)
    config.mux_enable_ssh_agent = true
    config.mux_env_remove = {
      "SSH_AUTH_SOCK",
      "SSH_CLIENT",
      "SSH_CONNECTION",
    }

    config.ssh_domains = config.ssh_domains or wezterm.default_ssh_domains()
    config.wsl_domains = config.wsl_domains or wezterm.default_wsl_domains()
    config.unix_domains = config.unix_domains or {}

    local unix_domains = {
      {
        name = "dotfiles",
      },
      {
        name = "gamma",
      },
    }

    table.insert(config.ssh_domains, {
      name = "nijusan.internal",
      remote_address = "nijusan.internal",
    })
    table.insert(config.ssh_domains, {
      name = "wijusan.internal",
      remote_address = "wijusan.internal",
    })
    table.insert(config.ssh_domains, {
      name = "logamma.internal",
      remote_address = "logamma.internal",
    })
    table.insert(config.ssh_domains, {
      name = "rpi4b.internal",
      remote_address = "rpi4b.internal",
    })
    table.insert(config.ssh_domains, {
      name = "rpi400.internal",
      remote_address = "rpi400.internal",
    })
    table.insert(config.ssh_domains, {
      name = "fire.walla",
      username = "pi",
      remote_address = "fire.walla",
    })
    table.insert(config.ssh_domains, {
      name = "gala-node",
      remote_address = "34.220.129.140",
      username = "ec2-user",
    })
  end,
}
