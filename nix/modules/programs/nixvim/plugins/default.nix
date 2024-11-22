{ pkgs, ... }:
{
  imports = [
    ./bufferline.nix
    ./comment.nix
    ./conform.nix
    ./lsp
    ./lualine.nix
    ./mini.nix
    ./nvim-autopairs.nix
    ./nvim-filetree.nix
    ./oil.nix
    ./project.nix
    ./supermaven
    ./telescope.nix
    ./treesitter.nix
    ./which-key.nix
    {
      programs.nixvim = {
        plugins = {
          direnv.enable = true;
          fugitive.enable = true;
          gitlinker.enable = true;
          illuminate.enable = true;
          lazy.enable = true;
          nix.enable = true;
          nvim-autopairs.enable = true;
          qmk.enable = false;
          snacks.enable = true;
          sniprun.enable = true;
          spectre.enable = true;
          trouble.enable = true;
          typescript-tools.enable = true;
          vim-surround.enable = true;
          web-devicons.enable = true;
        };
        extraPlugins = with pkgs.vimPlugins; [
          zoxide-vim
          vim-eunuch
          # vim-bbye
          # (pkgs.vimUtils.buildVimPlugin {
          #   name = "vim-symlink";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "aymericbeaumet";
          #     repo = "vim-symlink";
          #     rev = "fec2d1a72c6875557109ce6113f26d3140b64374";
          #     hash = "sha256-V5ziS/Q/0hulAdUIg7PgR+yjf6vljaGQBksUCiIeHyM=";
          #   };
          # })
        ];

      };
    }
  ];
}
