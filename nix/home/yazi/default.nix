{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    shellWrapperName = "yy";
    initLua = builtins.readFile ./init.lua;
    keymap = {
      # input.keymap = [
      #   { exec = "close"; on = [ "<C-q>" ]; }
      #   { exec = "close --submit"; on = [ "<Enter>" ]; }
      #   { exec = "escape"; on = [ "<Esc>" ]; }
      #   { exec = "backspace"; on = [ "<Backspace>" ]; }
      # ];
      # manager.keymap = [
      #   { exec = "escape"; on = [ "<Esc>" ]; }
      #   { exec = "quit"; on = [ "q" ]; }
      #   { exec = "close"; on = [ "<C-q>" ]; }
      # ];
    };
    plugins = {};
    settings = {
      manager = {
        show_hidden = false;
        sort_dir_first = true;
      };
    };
  };
}
