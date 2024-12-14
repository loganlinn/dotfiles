local wezterm = require("wezterm")

---@class patterns.registry
local registry = {
  EMAIL = {
    "[%w.+-]@[%w.+-]%.%w+",
  },
  FILE = {
    [[(?:[-._~/a-zA-Z0-9])*[/ ](?:[-._~/a-zA-Z0-9]+)]], -- unix paths
    "(?<= | | | | | | | | | | | | | |󰢬 | | | |└──|├──)\\s?(\\S+)", -- HACK: lsd/eza output.
  },
  GIT = {
    "[\\h]{7,40}", -- SHA1 hashes, usually used for Git.
  },
  NIX = {
    "sha256-.{44,128}", -- SHA256 hashes in Base64, used often in getting hashes for Nix packaging.
    "sha512-.{44,128}", -- SHA512 hashes in Base64, used often in getting hashes for Nix packaging.
  },
  URL = {},
}

setmetatable(registry, { __index = error })

for _, rule in ipairs(wezterm.default_hyperlink_rules()) do
  table.insert(registry.URL, rule.regex)
end

local M = {}

---@return string[]
M.all = function()
  local result = {}
  for _, group in pairs(registry) do
    for _, pattern in ipairs(group) do
      table.insert(result, pattern)
    end
  end
  return result
end

setmetatable(M, { __index = registry })

return M
