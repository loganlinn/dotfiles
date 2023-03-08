{
  perSystem = { pkgs, lib, config, system, ... }:
    let
      inherit (pkgs.stdenv) isLinux isDarwin;
      inherit (lib) getExe;

      flakeRootBin = getExe config.flake-root.package;
    in
    {

      mission-control.scripts = {

        repl = {
          description = "Start nix flake repl";
          exec = ''nix repl --file "$(${flakeRootBin})/repl.nix" "$@"'';
          category = "REPLs";
        };

        hm-repl = {
          description = "Start repl for home-manager configuration";
          exec = ''nix repl --file "$(${flakeRootBin})/home-manager/repl.nix" "$@"'';
          category = "REPLs";
        };

        os-repl = {
          description = "Start repl for nixos configuration";
          exec = ''nix repl --file "$(${flakeRootBin})/nixos/repl.nix" "$@"'';
          category = "REPLs";
        };

        # darwin-repl = {
        #   description = "Start repl for darwin configuration";
        #   exec = '''';
        # };

        switch = {
          description = "Build and activate configuration";
          exec = ''hm switch "$@"'';
          category = "Dev Tools";
        };

        build = {
          description = "Build configuration";
          exec = ''hm build "$@"'';
          category = "Dev Tools";
        };

        fmt = {
          description = "Format the source tree";
          exec = ''nix fmt'';
          category = "Dev Tools";
        };
      };

      devShells.default =
        let shell = pkgs.mkShell { };
        in config.mission-control.installToDevShell shell;
    };
}
