{ config, lib, ... }:

with lib;
let
  inherit (config.lib.nixvim) mkRaw;
in
{
  _file = ./default.nix;

  imports = [
    ./plugins
    ./keymaps.nix
  ];

  # options = {
  #   lib.nixivm.my = mkOption {
  #   };
  # };
  #
  config = {
    programs.nixvim = {
      vimAlias = !(config.programs.neovim.vimAlias or false);
      # colorscheme = "dracula";
      colorscheme = "catppuccin";
      colorschemes = {
        # dracula.enable = true;
        catppuccin.enable = true;
      };
      opts = {
        ignorecase = true;
        smartcase = true;
        number = true;
        relativenumber = true;
        clipboard = "unnamedplus";
        tabstop = 2;
        softtabstop = 2;
        showtabline = 2;
        expandtab = true;
        smartindent = true;
        shiftwidth = 2;
        breakindent = true;
        cursorline = true;
        scrolloff = 8;
        foldmethod = "expr";
        foldenable = true;
        linebreak = true;
        spell = false;
        swapfile = false;
        timeoutlen = 300;
        termguicolors = true;
        showmode = false;
        splitbelow = true;
        splitkeep = "screen";
        splitright = true;
      };
      globals = {
        mapleader = " ";
      };
      extraConfigVim = ''
        cnoreabbrev Q q
        cnoreabbrev Q! q!
        cnoreabbrev W w
        cnoreabbrev W! w!
        cnoreabbrev Wq wq
        cnoreabbrev Wq! wq!

        augroup UIEvents
          autocmd!
          autocmd VimResized * wincmd =
        augroup END
      '';
    };
  };
}
