{pkgs, ...}: {
  imports = [
    ./readline.nix
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

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    tealdeer.enable = true; # tldr command

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
