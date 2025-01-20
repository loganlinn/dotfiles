{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    plugins = {
      vim-dadbod.enable = true;
      vim-dadbod-ui.enable = true;
      vim-dadbod-completion.enable = true;
    };
    globals = {
      db_ui_use_nerd_fonts = 1;
      db_ui_show_database_icon = 1;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>od";
        action = "<cmd>DBUIToggle<cr>";
      }
    ];
  };
}
