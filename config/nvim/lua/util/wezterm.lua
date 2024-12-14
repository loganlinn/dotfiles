local base64 = require("util.base64")

local M = {}

---@param key string
---@param val string|boolean|number
function M.set_user_var(key, val)
  if vim.env.WEZTERM_IS_TMUX then
    -- UNTESTED!
    io.write(string.format("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\", key, base64(val)))
  else
    io.write(string.format("\027]1337;SetUserVar=%s=%s\a", key, base64(val)))
  end
end

function M.setup()
  if vim.env.WEZTERM_PANE then
    local wezterm = require("util.wezterm")
    local servers = vim.fn.serverlist()
    local server = servers and servers[1] or vim.fn.startserver()
    wezterm.set_user_var("NVIM_LISTEN_ADDRESS", server)
  end
end

return M
