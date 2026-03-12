-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Convert text to markdown link
vim.keymap.set("v", "gml", function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  
  if #lines == 1 then
    local text = string.sub(lines[1], start_pos[3], end_pos[3])
    local replacement = "[" .. text .. "]()"
    vim.fn.setline(start_pos[2], 
      string.sub(lines[1], 1, start_pos[3] - 1) .. replacement .. string.sub(lines[1], end_pos[3] + 1))
    vim.fn.cursor(start_pos[2], start_pos[3] + #text + 3)
  end
end, { desc = "Convert selection to markdown link" })
