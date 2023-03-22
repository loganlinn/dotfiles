{ pkgs, ... }: {
  imports = [
    ./readline.nix
    ./starship.nix
  ];

  programs.bat.enable = true;

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

  home.packages = with pkgs; [
  ];
}
