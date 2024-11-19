{ pkgs, ... }:
{
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

  programs.fzf = {
    enable = true;
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.tealdeer.enable = true; # tldr command

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  home.packages =
    with pkgs;
    [
    ];
}
