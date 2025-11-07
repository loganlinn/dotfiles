{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.nixvim;
in {
  programs.nixvim = {
    plugins.fugitive.enable = true;
    plugins.diffview.enable = true;

    keymaps = [
      # {
      #   mode = "n";
      #   key = "<leader>gd";
      #   action = "<cmd>Neogit diff<cr>";
      #   options.desc = "Neogit diff";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>gbb";
      #   action = "<cmd>Neogit branch<cr>";
      #   options.desc = "Neogit branch";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>gb";
      #   action.__raw = "require('neogit').action('branch', 'checkout_recent_branch')";
      #   options.desc = "Checkout recent branch";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>gg";
      #   action = "<cmd>Neogit<cr>";
      #   options.desc = "Neogit";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>gG";
      #   action = "<cmd>Telescope git_status<cr>";
      #   options.desc = "Status";
      # }
      # {
      #   mode = "v";
      #   key = "<leader>gL";
      #   action = "<cmd>'<,'>DiffviewFileHistory<CR>";
      #   options.desc = "File history";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>gz";
      #   action = "<cmd>Neogit stash<CR>";
      #   options.desc = "Stash";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>gc";
      #   action = "<cmd>Neogit commit<CR>";
      #   options.desc = "Commit";
      # }
      # {
      #   mode = [
      #     "n"
      #     "v"
      #   ];
      #   key = "<leader>gf";
      #   action = "<cmd>Telescope git_files<CR>";
      #   options.desc = "Git files";
      # }
      {
        mode = "n";
        key = "<leader>gS"; # doomemacs style
        action = "<cmd>Gwrite<cr>";
        options = {
          desc = "Stage file";
        };
      }
      {
        mode = "n";
        key = "<leader>gW";
        action = "<cmd>Gwrite<cr>";
        options.desc = "Stage file";
      }
      {
        mode = "n";
        key = "<leader>gU";
        action = "<cmd>Git reset -- %<cr>";
        options.desc = "Unstage file";
      }
      # {
      #   mode = "n";
      #   key = "<leader>goo";
      #   action = "<cmd>GBrowse<cr>";
      #   options.desc = "Open file URL";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>goy";
      #   action = "<cmd>GBrowse!<cr>";
      #   options.desc = "Yank file URL";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>grc";
      #   action.__raw = "require('neogit').action('branch', 'open_pull_request')";
      #   options.desc = "Open PR";
      # }
      # {
      #   mode = "n";
      #   key = "<leader>g~";
      #   action.__raw = ''
      #     function()
      #       require('neogit').open{cwd = vim.env.DOTFILES_DIR or "~/.dotfiles" }
      #     end'';
      # }
    ];
  };
}
