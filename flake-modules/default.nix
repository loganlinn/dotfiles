toplevel@{ self, inputs, lib, ... }:

{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
    ./options.nix
    ./mission-control.nix
  ];

  flake = {

    lib = import ../lib toplevel;

    # overlay = final: prev: { };

    # templates = { };

  };

  perSystem = { inputs', self', config, pkgs, lib, final, ... }: {

    overlayAttrs = {
      inherit (inputs'.home-manager.packages) home-manager;
      inherit (inputs'.devenv.packages) devenv;
      inherit (inputs'.emacs.packages) emacsGit emacsLsp emacsUnstable;
      inherit (config.packages) jdk;
    };

    # formatter = pkgs.nixfmt;
    # formatter = nixpkgs-fmt;
    formatter = pkgs.alejandra;

    packages = {
      jdk = lib.mkDefault pkgs.jdk;
    };

  };
}
