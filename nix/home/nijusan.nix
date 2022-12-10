{pkgs, ...}: {
  imports = [./zsh.nix ./mosh.nix];

  home.packages = with pkgs; [nodePackages.graphite-cli];

  services.emacs = {enable = true;};
}
