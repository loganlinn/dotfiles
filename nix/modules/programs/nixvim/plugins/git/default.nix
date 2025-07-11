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
    extraPlugins = with pkgs.vimPlugins; [
      # vim-rhubarb # Needed for fugitive :GBrowse
    ];

    plugins.fugitive.enable = true;

    # plugins.gitlinker.enable = true;

    plugins.diffview = {
      enable = true;
    };

    plugins.neogit = {
      enable = true;
      settings = {
        graph_style = "unicode";
        git_services."github.com" =
          "https://github.com/\${owner}/\${repository}/compare/\${branch_name}?expand=1";
        git_services."gitlab.com" =
          "https://gitlab.com/\${owner}/\${repository}/merge_requests/new?merge_request[source_branch]=\${branch_name}";
        git_services."git.sr.ht" =
          "https://git.sr.ht/~\${owner}/\${repository}/send-email?branch=\${branch_name}";
        git_services."bitbucket.org" =
          "https://bitbucket.org/\${owner}/\${repository}/pull-requests/new?source=\${branch_name}&t=1";
        integrations.diffview = cfg.plugins.diffview.enable;
        integrations.telescope = cfg.plugins.telescope.enable;
        # mappings.commit_editor."<c-g>" = "Abort";
        # mappings.commit_editor_I."<c-g>" = "Abort";
        # mappings.finder."<c-g>" = "Abort";
        # mappings.popup."<c-g>" = "Abort";
        # mappings.rebase_editor."<c-g>" = "Abort";
        # mappings.rebase_editor_I."<c-g>" = "Abort";
        # mappings.status."<c-g>" = "Abort";
      };
    };
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
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>Neogit<cr>";
        options.desc = "Neogit";
      }
      {
        mode = "n";
        key = "<leader>gG";
        action = "<cmd>Telescope git_status<cr>";
        options.desc = "Status";
      }
      # {
      #   mode = "v";
      #   key = "<leader>gL";
      #   action = "<cmd>'<,'>DiffviewFileHistory<CR>";
      #   options.desc = "File history";
      # }
      {
        mode = "n";
        key = "<leader>gz";
        action = "<cmd>Neogit stash<CR>";
        options.desc = "Stash";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Neogit commit<CR>";
        options.desc = "Commit";
      }
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
      {
        mode = "n";
        key = "<leader>g~";
        action.__raw = ''
          function()
            require('neogit').open{cwd = vim.env.DOTFILES_DIR or "~/.dotfiles" }
          end'';
      }
    ];
  };
}
