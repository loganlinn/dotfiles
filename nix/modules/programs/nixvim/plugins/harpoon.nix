{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    plugins = {
      harpoon = {
        enable = true;
        package = pkgs.vimPlugins.harpoon2;
        enableTelescope = true;
        # luaConfig.post = ''
        #   local harpoon = require("harpoon")
        #
        #   harpoon:setup()
        #
        #   vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        #   vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
        #
        #   vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
        #   vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
        #   vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
        #   vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
        #
        #   -- Toggle previous & next buffers stored within Harpoon list
        #   vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
        #   vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
        # '';
      };

      which-key.settings.spec = lib.optionals cfg.plugins.harpoon.enable [
        {
          __unkeyed-1 = "<leader>j";
          group = "Harpoon";
          icon = "󱡀 ";
        }
      ];
    };

    keymaps = lib.mkIf cfg.plugins.harpoon.enable [
      {
        mode = "n";
        key = "<leader>ja";
        options.desc = "Add file";
        action.__raw = "function() require'harpoon':list():add() end";
      }
      {
        mode = "n";
        key = "<leader>je";
        options.desc = "Quick Menu";
        action.__raw = "function() require'harpoon'.ui:toggle_quick_menu(require'harpoon':list()) end";
      }
      {
        mode = "n";
        key = "<leader>jj";
        options.desc = "1";
        action.__raw = "function() require'harpoon':list():select(1) end";
      }
      {
        mode = "n";
        key = "<leader>jk";
        options.desc = "2";
        action.__raw = "function() require'harpoon':list():select(2) end";
      }
      {
        mode = "n";
        key = "<leader>jl";
        options.desc = "3";
        action.__raw = "function() require'harpoon':list():select(3) end";
      }
      {
        mode = "n";
        key = "<leader>jm";
        options.desc = "4";
        action.__raw = "function() require'harpoon':list():select(4) end";
      }
    ];
  };
}
