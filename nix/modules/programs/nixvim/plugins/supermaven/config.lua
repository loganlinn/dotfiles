require("supermaven-nvim").setup({
  -- keymaps = {
  --   accept_suggestion = "<C-f>",
  --   clear_suggestion = "<C-]>",
  --   accept_word = "<C-j>",
  -- },
  --
  ignore_filetypes = {
    "envrc",
  },

  keymaps = {
    accept_suggestion = "<Tab>",
  },

  color = {
    suggestion_color = vim.api.nvim_get_hl(0, { name = "NonText" }).fg,
    cterm = vim.api.nvim_get_hl(0, { name = "NonText" }).cterm,
    suggestion_group = "NonText",
  },

  -- set to "off" to disable logging completely
  log_level = "error",

  -- disables inline completion for use with cmp
  disable_inline_completion = true,

  -- disables built in keymaps for more manual control
  disable_keymaps = false,

  -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
  condition = function()
    return string.match(vim.fn.expand("%:t"), ".envrc")
  end,
})
