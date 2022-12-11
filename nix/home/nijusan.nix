{pkgs, ...}: {
  imports = [
    ./zsh.nix
    ./git.nix
    ./gh.nix
  ];

  home.packages = with pkgs; [nodePackages.graphite-cli];

  services.emacs = {enable = true;};
}
