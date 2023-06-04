{pkgs, ...}: {
  # TODO reconcile with #nix/modules/fonts.nix
  options = {};
  config = {
    fonts.fonts = with pkgs; [
    ];
  };
}
