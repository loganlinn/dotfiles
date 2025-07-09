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
        breakindent = true;
        clipboard = "unnamedplus";
        cursorline = true;
        expandtab = true;
        exrc = true;
        foldenable = true;
        foldlevelstart = 99;
        foldmethod = "expr";
        ignorecase = true;
        linebreak = true;
        number = true;
        relativenumber = true;
        scrolloff = 8;
        shiftwidth = 2;
        showmode = false;
        showtabline = 2;
        smartcase = true;
        smartindent = true;
        softtabstop = 2;
        spell = false;
        splitbelow = true;
        splitkeep = "screen";
        splitright = true;
        swapfile = false;
        tabstop = 2;
        termguicolors = true;
        timeoutlen = 300;
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
