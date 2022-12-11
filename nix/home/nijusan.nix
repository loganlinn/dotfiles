{pkgs, ...}: {
  imports = [./zsh.nix ];

  home.packages = with pkgs; [nodePackages.graphite-cli];

  services.emacs = {enable = true;};
}
