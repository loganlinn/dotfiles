--[[ https://github.com/folke/dot/blob/48a708fa10ff0a15a84483483c039cc2791c0e3b/nvim/lua/util/init.lua#L107 ]]

local M = {}

---@param data string|boolean|number
---@return string
function M.base64(data)
  data = tostring(data)
  local bit = require("bit")
  local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  local b64, len = "", #data
  local rshift, lshift, bor = bit.rshift, bit.lshift, bit.bor

  for i = 1, len, 3 do
    local a, b, c = data:byte(i, i + 2)
    b = b or 0
    c = c or 0

    local buffer = bor(lshift(a, 16), lshift(b, 8), c)
    for j = 0, 3 do
      local index = rshift(buffer, (3 - j) * 6) % 64
      b64 = b64 .. b64chars:sub(index + 1, index + 1)
    end
  end

  local padding = (3 - len % 3) % 3
  b64 = b64:sub(1, -1 - padding) .. ("="):rep(padding)

  return b64
end

---@param key string
---@param val string|boolean|number
function M.set_user_var(key, val)
  if os.getenv("TMUX") then
    -- UNTESTED!
    io.write(string.format("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\", key, M.base64(val)))
  else
    io.write(string.format("\027]1337;SetUserVar=%s=%s\a", key, M.base64(val)))
  end
end

function M.wezterm()
  local nav = {
    h = "Left",
    j = "Down",
    k = "Up",
    l = "Right",
  }

  local function navigate(dir)
    return function()
      local win = vim.api.nvim_get_current_win()
      vim.cmd.wincmd(dir)
      local pane = vim.env.WEZTERM_PANE
      if vim.system and pane and win == vim.api.nvim_get_current_win() then
        local pane_dir = nav[dir]
        vim.system({ "wezterm", "cli", "activate-pane-direction", pane_dir }, { text = true }, function(p)
          if p.code ~= 0 then
            vim.notify(
              "Failed to move to pane " .. pane_dir .. "\n" .. p.stderr,
              vim.log.levels.ERROR,
              { title = "Wezterm" }
            )
          end
        end)
      end
    end
  end

  -- Move to window using the movement keys
  for key, dir in pairs(nav) do
    vim.keymap.set("n", "<" .. dir .. ">", navigate(key), { desc = "Go to " .. dir .. " window" })
    vim.keymap.set("n", "<C-" .. key .. ">", navigate(key), { desc = "Go to " .. dir .. " window" })
  end
end

if os.getenv("WEZTERM_PANE") then
  M.set_user_var("IS_NVIM", "true")
end

return M
