{
  pkgs,
  emacs,
  # nix-doom-emacs,
  ...
}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacsNativeComp;
    extraPackages = epkgs:
      with epkgs; [
        vterm
      ];
  };

  # programs.doom-emacs = {
  #   enable = true;
  #   doomPrivateDir = ../../config/doom;
  # };

  services.emacs = {
    enable = true;
  };
}
