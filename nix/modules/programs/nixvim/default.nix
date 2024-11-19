{ config, ... }:
{
  imports = [ ./plugins ];

  programs.nixvim = {
    vimAlias = !(config.programs.neovim.vimAlias or false);

    colorscheme = "dracula";

    colorschemes = {
      dracula.enable = true;
      # gruvbox.enable = true;
      kanagawa.enable = true;
      # nightfox.enable = true;
      # one.enable = true;
      # tokyonight.enable = true;
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

    keymaps = import ./keymaps.nix;

    extraConfigVim = ''
      cnoreabbrev Q q
      cnoreabbrev Q! q!
      cnoreabbrev W w
      cnoreabbrev W! w!
      cnoreabbrev Wq wq
      cnoreabbrev Wq! wq!
    '';
  };
}
