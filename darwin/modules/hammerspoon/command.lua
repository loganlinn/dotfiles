local logger = require("hs.logger")
local log = logger.new("command.lua", "debug")

local M = {}

-- https://github.com/NixOS/nixpkgs/blob/90c5252536decb2fb4d49586c273249c250342e4/lib/strings.nix#L1174-L1208
local function escapeShellArg(s)
  if string.find(s, "^[%w,._+:@%/-]+$") == nil then
    return "'" .. string.gsub(s, "'", "'\\''") .. "'"
  else
    return s
  end
end

local function execute(...)
  log.i("hs.execute", ...)
  local output, status, type, rc = hs.execute(...)
  log.i("status:", status, "type:", type, "rc:", rc)
  return output, status, type, rc
end

local function getexe(name)
  local out, ok = execute("command -v " .. escapeShellArg(name), true)
  return ok and string.gsub(out, "%s+", "") or nil
end

local Command = {}

Command.__index = function(self, key)
  -- First check if it's a method
  if Command[key] then
    return Command[key]
  end
end

function Command.__call(self, ...)
  return self:execute({ ... })
end

function Command:new(args)
  if type(args) == "string" then
    args = { args }
  elseif type(args) ~= "table" then
    error("expected table, got " .. type(args))
  end
  return setmetatable({
    args = args,
  }, self)
end

function Command:resolve()
  local command = self.args[1]
  local exe = getexe(command)
  if not exe then
    error("unable to resolve command: " .. command)
  end
  self.args[1] = exe
  return self
end

function Command:execute(args)
  local cmdline = ""
  for _, arg in ipairs(self.args) do
    cmdline = cmdline .. " " .. escapeShellArg(arg)
  end
  if type(args) == "string" then
    cmdline = cmdline .. " " .. escapeShellArg(args)
  elseif args ~= nil then
    for _, arg in ipairs(args) do
      cmdline = cmdline .. " " .. escapeShellArg(arg)
    end
  end
  return execute(cmdline)
end

function M.new(...)
  return Command:new(...)
end

local commands = setmetatable({}, {
  __index = function(self, name)
    if type(name) ~= "string" then
      error("expected string, got " .. type(name))
    end
    local cmd = M.new({ name })
    rawset(self, name, cmd)
    return cmd
  end,
})

M.execute = function(command, ...)
  return commands[command]:execute({ ... })
end

return M
