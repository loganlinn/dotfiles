{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    plugins.lazydev = {
      enable = lib.mkDefault true;
      settings.libraries = [
        "lazy.nvim"
        {
          path = pkgs.fetchFromGitHub {
            owner = "gonstoll";
            repo = "wezterm-types";
            rev = "45ef8d4d98d27be3ec2e472adde4b31df1d6edcb";
            hash = "sha256-kQJ7hzMAj7lbM83kZAqcslte1EqSY/2R6oSt5s0K/V0=";
          };
          mods = [ "wezterm" ];
        }
        {
          path = "luvit-meta/library";
          words = [ "vim%.uv" ];
        }
      ];
    };
    plugins.blink-cmp.settings = lib.mkIf cfg.plugins.lazydev.enable {
      sources.providers = {
        lazydev = {
          name = "LazyDev";
          module = "lazydev.integrations.blink";
          # make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100;
        };
      };
    };
  };
}
