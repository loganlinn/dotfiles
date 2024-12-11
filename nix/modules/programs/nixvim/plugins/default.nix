{ pkgs, ... }:
{
  imports = [
    ./bufferline.nix
    ./cmp.nix
    ./comment.nix
    ./conform.nix
    ./git
    ./harpoon.nix
    ./lazy.nix
    ./lsp
    ./lualine.nix
    ./mini.nix
    ./notify.nix
    ./nvim-tree.nix
    ./oil.nix
    ./project.nix
    ./supermaven
    ./telescope
    ./treesitter.nix
    ./typescript-tools.nix
    ./which-key.nix
    ./zen-mode.nix
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
      vim-surround.enable = true;
      web-devicons.enable = true;
    };
    extraPlugins = with pkgs.vimPlugins; [
      { plugin = lazydev-nvim; }
      { plugin = vim-just; }
      { plugin = vim-lion; }
      { plugin = zoxide-vim; }
      { plugin = nfnl; }
      { plugin = fennel-vim; }
      { plugin = neorepl-nvim; }
    ];
  };
}
