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
  imports = [
    ./auto-session.nix
    ./bufferline.nix
    ./cmp.nix
    ./comment.nix
    ./conform.nix
    ./early-retirement.nix
    ./git
    ./harpoon.nix
    ./lsp
    ./lualine.nix
    ./mini.nix
    ./neorepl.nix
    ./neotest.nix
    ./notify.nix
    ./nvim-tree.nix
    ./oil.nix
    ./project.nix
    ./supermaven
    ./telescope.nix
    ./treesitter.nix
    ./typescript-tools.nix
    ./which-key.nix
    ./zen-mode.nix
  ];
  programs.nixvim = {
    plugins = {
      direnv.enable = true;
      helpview.enable = true;
      luasnip.enable = true;
      nix.enable = true;
      noice.enable = true;
      notify.enable = true;
      nvim-autopairs.enable = true;
      colorizer.enable = true;
      # qmk.enable = false;
      snacks.enable = true;
      # sniprun.enable = true;
      # spectre.enable = true;
      trouble.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
    };
    extraPlugins = with pkgs.vimPlugins; [
      { plugin = fennel-vim; }
      { plugin = lazydev-nvim; }
      { plugin = nfnl; }
      { plugin = vim-abolish; }
      { plugin = vim-just; }
      { plugin = vim-lion; }
      { plugin = zoxide-vim; }
    ];
  };
}
