{ inputs, overlays, ... }:

{
  nixpkgs.overlays = [
    overlays.default
    inputs.rust-overlay.overlays.default
    inputs.emacs-overlay.overlays.default
  ];
}
