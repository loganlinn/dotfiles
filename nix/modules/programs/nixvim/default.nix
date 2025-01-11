{
  imports = [
    ./colorschemes.nix
    ./plugins
    ./keymaps.nix
    ./neovide.nix
  ];

  config = {
    programs.nixvim = {
      vimAlias = true;

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

      extraConfigLuaPre = ''
        local ok, wezterm = pcall(require, "util.wezterm")
        if ok then
          wezterm.setup{}
        end
        -- _G.dd = function(...) require("snacks.debug").inspect(...) end
        -- _G.bt = function(...) require("snacks.debug").backtrace() end
        -- _G.p = function(...) require("snacks.debug").profile(...) end
        -- vim.print = _G.dd
      '';

      extraConfigLua = ''
        -- require('kanagawa')
      '';

      extraConfigLuaPost = ''
        vim.diagnostic.config({
          virtual_text = false,
          underline = true,
          signs = true,
          severity_sort = true,
        })
      '';

      extraConfigVim = ''
        " Fat finger support for loganlinguiça
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
