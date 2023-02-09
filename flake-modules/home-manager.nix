{ self, config, inputs, withSystem, lib, ... }:

let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  hmConfigForSystem = system: module: perSystem@{ self', pkgs, ... }:
    lib.optionalAttrs (perSystem.system == system)
      (homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            _module.args.self = self;
            _module.args.inputs = inputs;

            imports = [ ../home-manager/common.nix ] ++ (lib.toList module);
            home.username = config.user.name;
            home.homeDirectory = config.user.home;
            home.packages = [ self'.packages.hm ];
          }
        ];
      });

in
{

  perSystem = ctx@{ self', pkgs, ... }: {

    legacyPackages.homeConfigurations = {
      "logan@nijusan" = hmConfigForSystem "x86_64-linux" ../home-manager/nijusan.nix ctx;
    };

    legacyPackages.homeConfigurations = {
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
