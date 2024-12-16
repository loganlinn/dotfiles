require("supermaven-nvim").setup({
  keymaps = {
    accept_suggestion = "<C-l>",
    accept_word = "<C-j>",
    clear_suggestion = "<C-e>",
  },

  ignore_filetypes = {
    "envrc",
  },

  color = {
    suggestion_color = vim.api.nvim_get_hl(0, { name = "NonText" }).fg,
    cterm = vim.api.nvim_get_hl(0, { name = "NonText" }).cterm,
    suggestion_group = "NonText",
  },

  -- set to "off" to disable logging completely
  log_level = "error",
})

vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#44bdff" })
