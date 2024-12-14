{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.nixvim;
  inherit (import ../../helpers.nix { inherit lib; }) mkKeymap;
in
{
  programs.nixvim = {
    plugins.fugitive.enable = true;
    plugins.gitlinker.enable = true;
    plugins.lazygit.enable = true;
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
    extraPlugins = with pkgs.vimPlugins; [ vim-rhubarb ]; # Enables :GBrowse from fugitive.vim to open GitHub URLs.
    keymaps = [
      {
        mode = "n";
        key = "<leader>gb";
        action.__raw = "require('neogit').action('branch', 'checkout_recent_branch')";
        options.desc = "Git files";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>Neogit<CR>";
        options.desc = "Neogit";
      }
      {
        mode = "n";
        key = "<leader>gG";
        action = "<cmd>File status<CR>";
        options.desc = "Neogit";
      }
      {
        mode = "n";
        key = "<leader>gL";
        action = "<cmd>DiffviewFileHistory %<CR>";
        options.desc = "File history";
      }
      {
        mode = "v";
        key = "<leader>gL";
        action = "<cmd>'<,'>DiffviewFileHistory<CR>";
        options.desc = "File history";
      }
      {
        mode = "n";
        key = "<leader>gt";
        action = "<cmd>Telescope git_stash<CR>";
        options.desc = "Git stash";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Neogit commit<CR>";
        options.desc = "Git commits";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>gf";
        action = "<cmd>Telescope git_files<CR>";
        options.desc = "Git files";
      }
      {
        mode = "n";
        key = "<leader>gS";
        action = "<cmd>Gwrite<cr>";
        options.desc = "Stage file";
      }
      {
        mode = "n";
        key = "<leader>gU";
        action = "<cmd>Git reset -- %<cr>";
        options.desc = "Unstage file";
      }
      {
        mode = "n";
        key = "<leader>goo";
        action = "<cmd>GBrowse<cr>";
        options.desc = "Open file URL";
      }
      {
        mode = "n";
        key = "<leader>goy";
        action = "<cmd>GBrowse!<cr>";
        options.desc = "Yank file URL";
      }
      {
        mode = "n";
        key = "<leader>grc";
        action.__raw = "require('neogit').action('branch', 'open_pull_request')";
        options.desc = "Open PR";
      }
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
