{pkgs, ...}: {
  imports = [
    ./readline.nix
    ./starship.nix
  ];

  programs = {
    bat.enable = true;

    bottom.enable = true;

    fzf = {
      enable = true;
    };

    htop.enable = true;

    lsd = {
      enable = true;
      enableAliases = true;
    };

    tealdeer.enable = true; # tldr command

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
