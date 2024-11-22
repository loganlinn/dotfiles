require("supermaven-nvim").setup({
  keymaps = {
    accept_suggestion = "<C-f>",
    clear_suggestion = "<C-]>",
    accept_word = "<C-j>",
  },

  ignore_filetypes = {
    "envrc",
  },

  -- set to "off" to disable logging completely
  log_level = "warn",

  -- disables inline completion for use with cmp
  disable_inline_completion = false,

  -- disables built in keymaps for more manual control
  disable_keymaps = false,

  -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
  condition = function()
    return string.match(vim.fn.expand("%:t"), ".envrc")
  end,
})
