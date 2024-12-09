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
  config = {
    programs.nixvim = {
      vimAlias = true;
      colorschemes.dracula.enable = true;
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
      autoCmd = [
        {
          event = "VimResized";
          pattern = "*";
          command = "wincmd =";
          desc = "Resize splits when vim is resized";
        }
      ];

      extraConfigLuaPre = ''

      '';

      extraConfigLua = ''

      '';

      extraConfigLuaPost = ''

      '';

      extraConfigVim = ''
        " Fat finger support by loganlinguiça
        cnoreabbrev Q q
        cnoreabbrev Q! q!
        cnoreabbrev W w
        cnoreabbrev W! w!
        cnoreabbrev Wq wq
        cnoreabbrev Wq! wq!
        cnoreabbrev Sort sort
      '';
    };
  };
}
