local wezterm = require("wezterm")

local patterns = setmetatable({}, { __index = error })

patterns.EMAIL = {
  "[%w.+-]@[%w.+-]%.%w+",
}
patterns.FILE = {
  [[(?:[-._~/a-zA-Z0-9])*[/ ](?:[-._~/a-zA-Z0-9]+)]], -- unix paths
  "(?<= | | | | | | | | | | | | | |󰢬 | | | | |󱁢|||└──|├──)\\s?(\\S+)", -- HACK: lsd/eza output.
}
patterns.GIT = {
  "[\\h]{7,40}", -- SHA1 hashes, usually used for Git.
}
patterns.NIX = {
  "sha256-.{44,128}", -- SHA256 hashes in Base64, used often in getting hashes for Nix packaging.
  "sha512-.{44,128}", -- SHA512 hashes in Base64, used often in getting hashes for Nix packaging.
}
patterns.URL = {}
for _, rule in ipairs(wezterm.default_hyperlink_rules()) do
  table.insert(patterns.URL, rule.regex)
end

local function apply_to_config(config)
  config.quick_select_patterns = config.quick_select_patterns or {}
  for _, pattern in pairs(patterns) do
    for _, regex in ipairs(pattern) do
      table.insert(config.quick_select_patterns, regex)
    end
  end
  return config
end

local function union(a, b)
  local out, seen = {}, {}
  for _, e in pairs(a) do
    if not seen[e] then
      table.insert(out, e)
      seen[e] = true
    end
  end
  for _, e in pairs(b) do
    if not seen[e] then
      table.insert(out, e)
      seen[e] = true
    end
  end
  return out
end

return setmetatable({
  union = union,
  apply_to_config = apply_to_config,
}, { __index = patterns })
