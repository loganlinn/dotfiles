return {
  plugins = {
    init = {
      {
        "kylechui/nvim-surround",
        config = function()
          require("nvim-surround").setup({})
        end,
      },
    },
  },
}
