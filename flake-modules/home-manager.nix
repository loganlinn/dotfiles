toplevel@{ self, config, inputs, withSystem, lib, ... }:

let

  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  hmConfigForSystem = system: module: perSystem@{ self', config, pkgs, ... }:
    lib.optionalAttrs (perSystem.system == system)
      (homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ../nix
          inputs.nix-colors.homeManagerModule
          {
            _module.args.self = self;
            _module.args.inputs = inputs;

            imports = [ ../home-manager/common.nix ] ++ (lib.toList module);
            home.username = config.my.user.name;
            home.homeDirectory = config.my.user.home;
            home.packages = [ self'.packages.hm ] ++ config.my.user.packages;
          }
        ];
      });

in
{

  perSystem = ctx@{ self', pkgs, ... }: {

    legacyPackages.homeConfigurations = {
      "logan@nijusan" = hmConfigForSystem "x86_64-linux" ../home-manager/nijusan.nix ctx;
      "logan@framework" = hmConfigForSystem "x86_64-linux" ../home-manager/framework.nix ctx;
    };

  } // (
    let
      hm = pkgs.writeShellApplication {
        name = "hm";
        runtimeInputs = with pkgs; [
          git
          coreutils
          nix
          jq
          unixtools.hostname
          inputs.home-manager.packages.${pkgs.system}.home-manager
        ];
        text = builtins.readFile ../home-manager/hm.sh;
      };
    in
    {
      apps.hm.program = "${hm}/bin/hm";
      packages.hm = hm;
    }
  );
}
