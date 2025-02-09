local wezterm = require("wezterm")

local M = setmetatable({}, {
  __index = function(_, k)
    error("Key does not exist: " .. tostring(k))
  end,
})

M.is = require("dotfiles.util.is")
M.safe = require("dotfiles.util.safe")
M.tbl = require("dotfiles.util.tbl")
M.delay = require("dotfiles.util.delay")
M.debug = require("dotfiles.util.debug")

---@generic T
---@param ... T
---@return T
M.spy = function(...)
  wezterm.log_info(...)
  return ...
end

--- Executes cmd and passes input to stdin
-- TODO: Deeper look into how to utilize wezterm's ExecDomain: https://wezterm.org/config/lua/ExecDomain.html
---@param command_string string command to be run
---@param input string input to stdin
---@return boolean
---@return string
---@credit https://github.com/MLFlexer/resurrect.wezterm/blob/c81eb4b02d15a6ae5060f6c1b34a4450990ccc02/plugin/init.lua
function M.exec_with_stdin(command_string, input)
  local is_windows = M.is_windows()

  if is_windows and #input < 32000 then -- Check if input is larger than max cmd length on Windows
    command_string =
      string.format("%s | %s", wezterm.shell_join_args({ "Write-Output", "-NoEnumerate", input }), command_string)
    local process_args = { "pwsh.exe", "-NoProfile", "-Command", command_string }

    local success, stdout, stderr = wezterm.run_child_process(process_args)
    if success then
      return success, stdout
    else
      return success, stderr
    end
  elseif #input < 150000 and not is_windows then -- Check if input is larger than common max on MacOS and Linux
    command_string = string.format("%s | %s", wezterm.shell_join_args({ "echo", "-E", "-n", input }), command_string)
    local process_args = { os.getenv("SHELL") or "bash", "-c", command_string }

    local success, stdout, stderr = wezterm.run_child_process(process_args)
    if success then
      return success, stdout
    else
      return success, stderr
    end
  else
    -- redirect stderr to stdout to test if cmd will execute
    -- can't check on Windows because it doesn't support /dev/stdin
    if not is_windows then
      local stdout = io.popen(command_string .. " 2>&1", "r")
      if not stdout then
        return false, "Failed to execute: " .. command_string
      end
      local stderr = stdout:read("*all")
      stdout:close()
      if stderr ~= "" then
        wezterm.log_error(stderr)
        return false, stderr
      end
    end
    -- if no errors, execute cmd using stdin with input
    local stdin = io.popen(command_string, "w")
    if not stdin then
      return false, "Failed to execute: " .. command_string
    end
    stdin:write(input)
    stdin:flush()
    stdin:close()
    return true, '"' .. command_string .. '" <input> ran successfully.'
  end
end

---@generic T
---@param v T|T[]
---@return T[]
M.tolist = function(v)
  if not M.is.table(v) or #v == 0 and next(v) ~= nil then
    return { v }
  end
  return v
end

---@param s string
---@param prefix string
---@return boolean
M.startswith = function(s, prefix)
  return string.sub(s, 1, #prefix) == prefix
end

---@param s string
---@param suffix string
---@return boolean
M.endswith = function(s, suffix)
  return suffix == "" or string.sub(s, -#suffix) == suffix
end

function M.basename(pathname)
  if pathname == nil then
    return "."
  elseif type(pathname) ~= "string" then
    error("pathname must be string", 2)
  end

  -- remove trailing-slashes
  local head = string.find(pathname, "/+$", 2)
  if head then
    pathname = string.sub(pathname, 1, head - 1)
  end

  -- extract last-segment
  head = string.find(pathname, "[^/]+$")
  if head then
    pathname = string.sub(pathname, head)
  end

  -- empty
  if pathname == "" then
    return "."
  end

  return pathname
end

---@param str string
---@param min_width number
---@return string
function M.pad(str, min_width)
  return wezterm.pad_left(wezterm.pad_right(str, min_width), min_width)
end

---@param pathname string
---@return string
M.dirname = function(pathname)
  if pathname == nil then
    return "."
  elseif type(pathname) ~= "string" then
    error("pathname must be string", 2)
  end

  -- remove trailing-slashes
  local head = string.find(pathname, "/+$", 2)
  if head then
    pathname = string.sub(pathname, 1, head - 1)
  end

  -- remove last-segment
  head = string.find(pathname, "[^/]+$")
  if head then
    pathname = string.sub(pathname, 1, head - 1)
  end

  -- remove trailing-slashes
  head = string.find(pathname, "/+$")
  if head then
    if head == 1 then
      return "/"
    end
    pathname = string.sub(pathname, 1, head - 1)
  end

  -- empty or dotted string
  if string.find(pathname, "^%s*$") or string.find(pathname, "^%.+$") then
    return "."
  end

  return pathname
end

M.is_darwin = M.delay(function()
  return M.endswith(wezterm.target_triple, "apple-darwin")
end)

M.is_linux = M.delay(function()
  return M.endswith(wezterm.target_triple, "linux-gnu")
end)

M.is_windows = M.delay(function()
  return M.endswith(wezterm.target_triple, "windows-msvc")
end)

---@generic T
---@param t { linux?: T, darwin?: T, windows?: T, default?: T }
---@return T
function M.match_platform(t)
  if M.is_linux() then
    return t.linux
  elseif M.is_darwin() then
    return t.darwin
  elseif M.is_windows() then
    return t.windows
  end
  return t.default or error("no platform matched")
end

function M.is_readable(path)
  local file = io.open(path, "r")
  wezterm.log_info("is_readable", path, file ~= nil)
  if file then
    io.close(file)
    return true
  end
  return false
end

---Returns a UNIX timestamp
---@param time? wezterm.Time Specific time to use, defaults to current time.
---@return number The number of milliseconds since 1970-01-01 00:00 UTC.
function M.unix_timestamp_ms(time)
  if time == nil then
    time = wezterm.time.now()
  end
  return tonumber(time:format("%s%.f")) * 1000
end

---@param t1 wezterm.Time
---@param t2 wezterm.Time
---@return number
function M.time_diff_ms(t1, t2)
  return M.unix_timestamp_ms(t1) - M.unix_timestamp_ms(t2)
end

function M.event_counter(event)
  local counter = require("dotfiles.util.atom"):new("event.count\00" .. event)
  counter:swap(function(current)
    return current or 0
  end)
  local inc = wezterm.on(event, function(window, pane, ...)
    counter:swap(M.inc, window, pane)
  end)
  return counter
end

return M
