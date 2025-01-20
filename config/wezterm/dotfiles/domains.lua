local wezterm = require("wezterm")

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

return {
  apply_to_config = function(config)
    local ssh_domains = {
      { name = "nijusan.internal", remote_address = "nijusan.internal" },
      { name = "wijusan.internal", remote_address = "wijusan.internal" },
      { name = "logamma.internal", remote_address = "logamma.internal" },
      { name = "rpi4b.internal", remote_address = "rpi4b.internal" },
      { name = "rpi400.internal", remote_address = "rpi400.internal" },
      { name = "fire.walla", username = "pi", remote_address = "fire.walla" },
      { name = "gala-node", remote_address = "34.220.129.140", username = "ec2-user" },
    }
    for _, domain in ipairs(config.domains or wezterm.default_ssh_domains()) do
      table.insert(ssh_domains, domain)
    end
    config.ssh_domains = ssh_domains
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
    return config
  end,
}
