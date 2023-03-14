{ inputs, ... }:

{
  perSystem = { pkgs, lib, config, system, ... }:
    let
      inherit (pkgs.stdenv) isLinux isDarwin;
      inherit (lib) getExe;

      flakeRootBin = getExe config.flake-root.package;
    in
    {

      mission-control.scripts = {

        z = {
          description = "Start (named) nix repl";
          exec = ''nix repl --file "$(${flakeRootBin})/''${1-}''${1+/}repl.nix" "$@"'';
        };

        s = {
          description = "Build and activate configuration";
          exec = ''hm switch "$@"'';
        };

        b = {
          description = "Build configuration";
          exec = ''hm build "$@"'';
        };

        f = {
          description = "Format the source tree";
          exec = ''nix fmt'';
        };

        home-manager = {
          description = "Runs home-manager";
          exec = inputs.home-manager.packages.${system}.home-manager;
        };

        # d = {
        #   description = "Runs darwin";
        #   exec = inputs.home-manager.packages.${system}.home-manager;
        # };
      };

      devShells.default =
        let shell = pkgs.mkShell { };
        in config.mission-control.installToDevShell shell;
    };
}
