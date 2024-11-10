{ pkgs, lib, ... }:
{
  imports = [
    ./bufferline.nix
    ./comment.nix
    ./conform.nix
    ./lualine.nix
    ./lsp
    ./mini.nix
    ./nvim-autopairs.nix
    ./nvim-filetree.nix
    ./oil.nix
    ./telescope.nix
    ./treesitter.nix
    ./supermaven
    ./which-key.nix
    {
      programs.nixvim = {
        plugins = {
          direnv.enable = true;
          fugitive.enable = true;
          gitlinker.enable = true;
          illuminate.enable = true; # highlight other instances of word
          nix.enable = true;
          qmk.enable = false;
          trouble.enable = true;
          typescript-tools.enable = true;
          vim-surround.enable = true;
          web-devicons.enable = true;
          # yanky.enable = true;
        };
        extraPlugins = with pkgs.vimPlugins; [
          zoxide-vim
        ];
      };
    }
    {
      programs.nixvim = {
        plugins.project-nvim = {
          enable = true;
          enableTelescope = true;
          settings = {
            detection_methods = [
              "lsp"
              "pattern"
            ];
            patterns = [
              ".git"
              "_darcs"
              ".hg"
              ".bzr"
              ".svn"
              "Makefile"
              "package.json"
              "deps.edn"
              "pyproject.toml"
              "Cargo.toml"
              "go.mod"
            ];
            scope_chdir = "tab";
            show_hidden = true;
            silent_chdir = false;
          };
        };
      };
    }
    {
      programs.nixvim = {
        plugins.bufdelete.enable = true;
        keymaps = [
          {
            key = "<leader>bd";
            action = "<cmd>:bwipeout<cr>"; # does not close split
            options.desc = "Wipeout buffer";
          }
          {
            key = "<leader>bk";
            action = "<cmd>:bwipeout<cr>"; # does not close split
            options.desc = "Wipeout buffer";
          }
        ];
      };
    }
    {
      programs.nixvim = {
        plugins.smart-splits = {
          enable = false;
        };
      };
    }
  ];
}
