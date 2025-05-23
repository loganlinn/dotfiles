{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./readline.nix
    ./shell/starship.nix
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };

  programs.bottom.enable = true;

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    bat-extras.prettybat
    bat-extras.batwatch
    bat-extras.batpipe
    bat-extras.batman
    bat-extras.batgrep
    bat-extras.batdiff
  ];

  my.shellInitExtra = ''
    help() {
      "$@" --help 2>&1 | bat --plain --language=help
    }
  '';
}
