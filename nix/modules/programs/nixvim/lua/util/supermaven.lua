local M = {}

M.expand = function(fallback)
  local has_luasnip, luasnip = pcall(require, "luasnip")
  if has_luasnip and luasnip.expandable() then
    luasnip.expand()
    return
  end
  local suggestion = require("supermaven-nvim.completion_preview")
  if suggestion.has_suggestion() then
    suggestion.on_accept_suggestion()
  else
    fallback()
  end
end

return M
