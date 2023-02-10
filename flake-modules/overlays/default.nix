{ self, inputs, lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = { inputs', self', config, pkgs, final, ... }: {
    overlayAttrs = {
      inherit (inputs'.home-manager.packages) home-manager;
      inherit (inputs'.devenv.packages) devenv;
      inherit (inputs'.emacs.packages) emacsGit emacsLsp emacsUnstable;
      inherit (config.packages) jdk;
    };

    packages.jdk = mkDefault pkgs.jdk;

  };
}
