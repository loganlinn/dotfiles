{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixvim;
  worktreeEnabled = builtins.elem pkgs.vimPlugins.git-worktree-nvim cfg.extraPlugins;
  worktreeTelescopeEnabled = worktreeEnabled && cfg.plugins.telescope.enable;
in
{
  programs.nixvim = {
    # logs to a git-worktree-nvim.log file that resides in Neovim's cache path. (:echo stdpath("cache") to find where that is for you.)
    globals.git_worktree_log_level = "debug";

    extraPlugins = [ pkgs.vimPlugins.git-worktree-nvim ];

    extraConfigLua = ''
      -- local git_worktree = require("git-worktree")
      --
      -- git_worktree.setup({
      --   change_directory_command = "tcd", -- change pwd of current vim tab only
      -- })
      --
      -- git_worktree.on_tree_change(function(op, metadata)
      --   if op == git_worktree.Operations.Switch then
      --     vim.notify("Switched from " .. metadata.prev_path .. " to " .. metadata.path)
      --   elseif op == git_worktree.Operations.Create then
      --     vim.notify("Created worktree at " .. metadata.path .. " on " .. metadata.branch)
      --   elseif op == git_worktree.Operations.Delete then
      --     vim.notify("Deleted worktree at " .. metadata.path)
      --   end
      -- end)

      local git_worktree_hooks = require("git-worktree.hooks")
      local git_worktree_config = require('git-worktree.config')

      git_worktree_config.change_directory_command = "tcd" -- change pwd of current vim tab only

      git_worktree_hooks.register(git_worktree_hooks.type.CREATE, function (...)
        vim.notify("git-worktree: created", { ... })
      end)

      git_worktree_hooks.register(git_worktree_hooks.type.SWITCH, function (...)
        vim.notify("git-worktree: switched", { ... })
      	git_worktree_hooks.builtins.update_current_buffer_on_switch(to, from)
      end)

      git_worktree_hooks.register(git_worktree_hooks.type.DELETE, function (...)
        vim.notify("git-worktree: delete", { ... })
        if git_worktree_config.update_on_change_command then
      	  vim.cmd(git_worktree_config.update_on_change_command)
      	end
      end)
    '';

    plugins = {
      # TODO: upstream nixpkg package change to use new fork
      # TODO: upstream module change to not call setup with new fork
      # git-worktree = {
      #   enable = true;
      #   enableTelescope = config.plugins.telescope.enable;
      #
      #   # FIXME: telescope extension loading issue
      #   # lazyLoad.settings.cmd = [
      #   #   "Telescope git_worktree"
      #   # ];
      # };

      telescope.enabledExtensions = lib.optionals worktreeTelescopeEnabled [ "git_worktree" ];

      which-key.settings.spec = lib.optionals worktreeTelescopeEnabled [
        {
          __unkeyed-1 = "<leader>gt";
          group = "Worktree";
          icon = "󰙅 ";
        }
      ];
    };

    keymaps = lib.optionals worktreeTelescopeEnabled [
      {
        mode = "n";
        key = "<leader>gtn";
        action = "<cmd>Telescope git_worktree create_git_worktree<CR>";
        options = {
          desc = "Create worktree";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>gtt";
        action = "<cmd>Telescope git_worktree<CR>";
        options = {
          desc = "Git Worktree";
        };
      }
      {
        mode = "n";
        key = "<leader>gtT";
        action = "<cmd>Telescope git_worktree git_worktree<CR>";
        options = {
          desc = "Switch / Delete worktree";
          silent = true;
        };
      }
    ];
  };
}
