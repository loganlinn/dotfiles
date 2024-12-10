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

      # diagnostics = {
      #   virtual_lines.only_current_line = true;
      # };

      extraFiles."lua/util/init.lua".source = ./lua/util/init.lua;

      extraConfigLuaPre = ''
        if vim.env.VSCODE then
          vim.g.vscode = true
        end

        -- if vim.loader then
        --   vim.loader.enable()
        -- end

        -- _G.dd = function(...)
        --   require("snacks.debug").inspect(...)
        -- end
        -- _G.bt = function(...)
        --   require("snacks.debug").backtrace()
        -- end
        -- _G.p = function(...)
        --   require("snacks.debug").profile(...)
        -- end
        -- vim.print = _G.dd
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
