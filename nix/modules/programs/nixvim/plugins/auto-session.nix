{ config, lib, ... }:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    plugins.auto-session = {
      enable = true;
      settings = {
        lazyLoad = true;
        keys = [
          {
            mode = "n";
            key = "<leader>qs";
            action = "<cmd>SessionSave<cr>";
            options.desc = "Save session";
          }
          {
            mode = "n";
            key = "<leader>qd";
            action = "<cmd>SessionDelete<cr>";
            options.desc = "Delete session";
          }
          {
            mode = "n";
            key = "<leader>qD";
            action = "<cmd>Autosession delete<cr>";
            options.desc = "Delete a session";
          }
          {
            mode = "n";
            key = "<leader>qP";
            action = "<cmd>SessionPurgeOrphaned<cr>";
            options.desc = "Purge orphaned sessions";
          }
          {
            mode = "n";
            key = "<leader>qL";
            action = "<cmd>Autosession search<cr>";
            options.desc = "Restore a session";
          }
          {
            mode = "n";
            key = "<leader>ql";
            action = "<cmd>SessionRestore<cr>";
            options.desc = "Restore session";
          }
          {
            mode = "n";
            key = "<leader>tS";
            action = "<cmd>SessionToggleAutoSave<cr>";
            options.desc = "Toggle session auto-save";
          }
        ];
        show_auto_restore_notif = true;
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
