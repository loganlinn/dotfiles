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

  services.emacs = {
    enable = true;
  };
}
