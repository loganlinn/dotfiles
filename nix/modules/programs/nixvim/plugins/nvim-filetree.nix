{ pkgs, lib, ... }:
with lib;
{
  programs.nixvim = {
    plugins.nvim-tree =
      {
        enable = true;
        autoClose = true;
        openOnSetup = true;
        git.enable = true;
        git.ignore = false;
        renderer.indentWidth = 1;
        diagnostics.enable = true;
        view.float.enable = true;
        updateFocusedFile.enable = true;
        liveFilter.alwaysShowFolders = false;
      }
      // optionalAttrs pkgs.stdenv.isDarwin {
        trash.cmd = "/usr/bin/trash";
      };

    keymaps = [
      {
        mode = "n";
        key = "<leader>op";
        action = "<cmd>lua require('nvim-tree.api').tree.toggle()<CR>";
        options.desc = "Toggle Tree";
      }
    ];

    # https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes

    # extraFiles."nvim-tree.lua".text = ''
    #   local api = require("nvim-tree.api")
    #
    #   local git_add = function()
    #     local node = api.tree.get_node_under_cursor()
    #     local gs = node.git_status.file
    #
    #     -- If the current node is a directory get children status
    #     if gs == nil then
    #       gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1]) 
    #            or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
    #     end
    #
    #     -- If the file is untracked, unstaged or partially staged, we stage it
    #     if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
    #       vim.cmd("silent !git add " .. node.absolute_path)
    #     -- If the file is staged, we unstage
    #     elseif gs == "M " or gs == "A " then
    #       vim.cmd("silent !git restore --staged " .. node.absolute_path)
    #     end
    #
    #     api.tree.reload()
    #   end
    # '';
  };
}
