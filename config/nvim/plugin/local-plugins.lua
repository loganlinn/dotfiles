-- Writable plugin configuration for NixVim. Keep setup in lazy hooks.
-- https://github.com/lumen-oss/lz.n#plugin-spec
local furball = vim.fn.expand("~/src/github.com/loganlinn/furball.nvim")

require("lz.n").load({
  {
    "furball.nvim",
    enabled = vim.fn.isdirectory(furball) == 1,
    cmd = { "Furball", "FurballPlan", "FurballRefresh" },
    load = function()
      vim.opt.runtimepath:prepend(furball)
      vim.cmd.runtime("plugin/furball.lua")
    end,
    -- Defaults use KITTY_LISTEN_ON; setup is optional. Put custom options in
    -- an after = function() require("furball").setup({ ... }) end hook.
  },
})
