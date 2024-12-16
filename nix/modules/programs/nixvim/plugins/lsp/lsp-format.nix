{
  programs.nixvim = {
    plugins.lsp-format = {
      enable = true;
      settings = {
        typescript = {
          tab_width.__raw = ''function() return vim.opt.shiftwidth:get() end'';
        };
        yaml = {
          tab_width = 2;
        };
      };
    };
  };
}
