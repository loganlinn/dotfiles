local wezterm = require("wezterm")
local log = require("dotfiles.util.logger")("domains.lua")

local some = function(x)
  if type(x) == "string" then
    if x == "" then
      x = nil
    end
  elseif type(x) == "table" then
    if next(x) == nil then
      x = nil
    end
  end
  return x
end

local function with_domains(config, domains)
  config.unix_domains = config.unix_domains or {}
  config.ssh_domains = config.ssh_domains or {}
  config.wsl_domains = config.wsl_domains or {}

  for _, domain in pairs(domains) do
    local url
    if type(domain) == "table" then
      if type(domain[1] == "string") then
        url = wezterm.url.parse(domain[1])
        domain[1] = nil
      end
    elseif type(domain) == "string" then
      url = wezterm.url.parse(domain)
      domain = {}
    end

    local cfg
    if url == nil then
      log.info("skipping", domain)
    elseif url.scheme == "ssh" then -- ssh://user@machine
      cfg = config.ssh_domains
      domain.remote_address = domain.remote_address or some(url.host)
      domain.remote_wezterm_path = domain.remote_wezterm_path or some(url.path)
      domain.user = domain.user or some(url.username)
    elseif url.scheme == "unix" then -- unix://
      cfg = config.unix_domains
      domain.name = domain.name or some(url.host) or "unix"
      domain.path = domain.path or some(url.path)
      table.insert(config.unix_domains, domain)
    elseif url.scheme == "wsl" then -- wsl://root@Ubuntu-18.04:/home/root
      cfg = config.wsl_domains
      domain.distribution = domain.distribution or some(url.host)
      domain.default_cwd = domain.default_cwd or some(url.path)
      domain.username = domain.username or some(url.username)
    else
      log.error("Unsupported scheme", url)
    end
    if cfg then
      if not domain.name and url then
        domain.name = string.gsub(tostring(url), "^.*://", "")
      end
      table.insert(cfg, domain)
    end
  end

  return config
end

---@param config Config
---@return Config
local function apply_to_config(config, domains)
  return with_domains(config, domains)
end

return {
  apply_to_config = apply_to_config,
}
