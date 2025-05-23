{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (config.lib.nixvim) mkRaw;
in {
  programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      autoClose = true;
      autoReloadOnWrite = true;
      git.ignore = false;
      liveFilter.alwaysShowFolders = false;
      openOnSetup = true;
      openOnSetupFile = false;
      renderer.icons.gitPlacement = "signcolumn";
      renderer.icons.show.git = false;
      renderer.indentMarkers.enable = true;
      updateFocusedFile.enable = true;
      view.signcolumn = "yes";
      view.width = 40;
      trash = optionalAttrs pkgs.stdenv.isDarwin {
        cmd = "/usr/bin/trash"; # avaiilble since macOS 14.0
      };
      # onAttach = mkRaw ''
      #   function(buffer)
      #     -- FIXME: <gt> not working, and tree resizes after losing focus anyway
      #     vim.keymap.set("n", "<lt>", function() require("nvim-tree.api").tree.resize({ width = { relative = "-3" }}) end, { buffer = buffer, noremap = true, silent = true, nowait = true, desc = "Increase width" })
      #     vim.keymap.set("n", "<gt>", function() require("nvim-tree.api").tree.resize({ width = { relative = "+3" }}) end, { buffer = buffer, noremap = true, silent = true, nowait = true, desc = "Decrease width" })
      #   end
      # '';
    };
    autoCmd = [
      {
        # https://github.com/nvim-tree/nvim-tree.lua/issues/1992#issuecomment-1467085424
        event = ["FileType"];
        pattern = ["NvimTree"];
        callback.__raw = ''
          function(args)
            vim.api.nvim_buf_delete(args.buf, { force = true })
            return true
          end
        '';
      }
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>op";
        action.__raw = ''function() require('nvim-tree.api').tree.toggle{ find_file = false } end'';
        options.desc = "Project tree";
      }
      {
        mode = "n";
        key = "<leader>oP";
        action.__raw = ''function() require('nvim-tree.api').tree.toggle{ find_file = true } end'';
        options.desc = "File tree";
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
