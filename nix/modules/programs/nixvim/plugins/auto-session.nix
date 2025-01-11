{ config, lib, ... }:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    plugins.auto-session = {
      enable = true;
      settings = {
        keys = [
          {
            mode = "n";
            key = "<leader>qs";
            action = "<cmd>SessionSave<cr>";
            options.desc = "Session save";
            options.silent = true;
          }
          {
            mode = "n";
            key = "<leader>qd";
            action = "<cmd>SessionSave<cr>";
            options.desc = "Session delete";
            options.silent = true;
          }
        ];

        pre_save_cmds.__raw = ''
          {
            require("nvim-tree.api").tree.close
          }
        '';
      };
    };

    # https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#workaround-when-using-rmagattiauto-session
    autoCmd = (
      lib.optional cfg.plugins.nvim-tree.enable {
        event = "BufEnter";
        pattern = "NvimTree*";
        callback.__raw = ''
          function()
            if not require("nvim-tree.view").is_visible() then
              require("nvim-tree.api").tree.open()
            end
          end
        '';
      }
    );
  };
}
