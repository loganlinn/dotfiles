{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.yazi;
in {
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
      flavor = {
        use = "dracula";
      };
      manager = {
        show_hidden = false;
        sort_dir_first = true;
      };
    };
  };
  xdg.configFile = {
    "yazi/flavors/dracula.yazi".source = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "yazi";
      rev = "99b60fd76df4cce2778c7e6c611bfd733cf73866";
      hash = "sha256-dFhBT9s/54jDP6ZpRkakbS5khUesk0xEtv+xtPrqHVo=";
    };
  };
}
