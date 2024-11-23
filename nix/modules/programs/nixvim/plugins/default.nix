{ pkgs, ... }:
{
  imports = [
    ./bufferline.nix
    ./comment.nix
    ./conform.nix
    ./lazy.nix
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
          { plugin = vim-just; }
          { plugin = zoxide-vim; }
        ];
      };
    }
  ];
}
