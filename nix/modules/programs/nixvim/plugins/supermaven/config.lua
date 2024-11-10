require("supermaven-nvim").setup {
  keymaps = {
    accept_suggestion = "<Tab>",
    clear_suggestion = "<C-]>",
    accept_word = "<C-j>"
  },

  ignore_filetypes = { cpp = true },

  -- color = {
  --   suggestion_color = "#ffffff",
  --   cterm = 244,
  -- },

  -- set to "off" to disable logging completely
  log_level = "info",

  -- disables inline completion for use with cmp
  disable_inline_completion = false,

  -- disables built in keymaps for more manual control
  disable_keymaps = false,

  -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
  condition = function() return false end
}
