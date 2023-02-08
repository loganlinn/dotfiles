{ self, inputs, lib, ... }:

let

in
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = { inputs', config, pkgs, final, ... }: {
    overlayAttrs = {
      inherit (inputs'.home-manager.packages) home-manager;
      inherit (inputs'.devenv.packages) devenv;
      inherit (inputs'.emacs.packages) emacsGit emacsLsp emacsUnstable;
    };
  };
}
