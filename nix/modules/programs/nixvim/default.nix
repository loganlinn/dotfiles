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
        exrc = true;
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

      # https://neovim.io/doc/user/diagnostic.html#vim.Diagnostic
      diagnostic.settings = {
        float = true;
        jump.float = false;
        jump.wrap = true;
        severity_sort = true;
        signs = true;
        underline = true;
        update_on_insert = false;
        virtual_lines = false;
        virtual_text = false;
      };

      extraConfigLuaPre = ''
        local ok, wezterm = pcall(require, "util.wezterm")
        if ok then
          wezterm.setup{}
        end
      '';

      extraConfigLua = ''
        -- require('kanagawa')
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
