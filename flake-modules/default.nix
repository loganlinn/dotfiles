toplevel@{ self, inputs, lib, ... }:

{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
    ../home-manager/flake-module.nix
    ../nixos/flake-module.nix
    ./options.nix
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

    formatter = pkgs.alejandra;

    devShells = {
      default = inputs.devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [ ../devenv.nix ];
      };
    };

    packages = {
      jdk = lib.mkDefault pkgs.jdk;
    };

  };
}
