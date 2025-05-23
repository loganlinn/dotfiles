{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      {plugin = neorepl-nvim;}
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>or";
        action.__raw = ''
          function()
            local buf = vim.api.nvim_get_current_buf()
            local win = vim.api.nvim_get_current_win()

            vim.cmd('split')

            require('neorepl').new{
              lang = 'vim',
              buffer = buf,
              window = win,
            }

            -- resize repl window and make it fixed height
            vim.cmd('resize 10 | setl winfixheight')
          end
        '';
        options.desc = "REPL";
        options.silent = true;
      }
    ];
  };
}
