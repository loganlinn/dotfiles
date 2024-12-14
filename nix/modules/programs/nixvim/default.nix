{ config, lib, ... }:
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

      diagnostics = {
        virtual_lines.only_current_line = true;
      };

      # TODO proper file listing
      extraFiles."lua/util/wezterm.lua".source = ./lua/util/wezterm.lua;
      extraFiles."lua/util/base64.lua".source = ./lua/util/base64.lua;
      extraFiles."lua/util/supermaven.lua".source = ./lua/util/supermaven.lua;

      extraConfigLuaPre = ''
        if vim.env.WEZTERM_PANEL then
          local wezterm = require('util.wezterm')
          wezterm.set_user_var("IS_NVIM", "true")
          wezterm.set_user_var("NVIM_SERVER", serverstart())
        end

        -- _G.dd = function(...) require("snacks.debug").inspect(...) end
        -- _G.bt = function(...) require("snacks.debug").backtrace() end
        -- _G.p = function(...) require("snacks.debug").profile(...) end
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
