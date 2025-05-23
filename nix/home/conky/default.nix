{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  home.packages = with pkgs; [conky];

  # xdg.configFile."conky/conky.conf".source = ./conky.conf;

  xdg.dataFile."conky/lcc".source = pkgs.fetchFromGitHub {
    owner = "jxai";
    repo = "lean-conky-config";
    rev = "v0.8.0";
    hash = "sha256-GBaCCtpqas3fakNJurG17A9QHM3TsgaWCnTodd+tX78=";
  };
}
