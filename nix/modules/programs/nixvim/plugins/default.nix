{ pkgs, ... }:
{
  imports = [
    ./bufferline.nix
    ./comment.nix
    ./conform.nix
    ./harpoon.nix
    ./git
    ./lazy.nix
    ./lsp
    ./lualine.nix
    ./mini.nix
    ./nvim-tree.nix
    ./oil.nix
    ./project.nix
    ./supermaven
    ./telescope
    ./treesitter.nix
    ./which-key.nix
  ];
  programs.nixvim = {
    plugins = {
      direnv.enable = true;
      helpview.enable = true;
      illuminate.enable = true;
      nix.enable = true;
      noice.enable = true;
      notify.enable = true;
      nvim-autopairs.enable = true;
      nvim-colorizer.enable = true;
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
      { plugin = lazydev-nvim; }
      { plugin = vim-just; }
      { plugin = vim-lion; }
      { plugin = zoxide-vim; }
    ];
  };
}
