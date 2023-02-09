{ self, config, inputs, withSystem, lib, ... }:

let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  hmConfigForSystem = system: module: ctx@{ self', pkgs, ... }:
    # lib.optionalAttrs (system == ctx.system)
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

    # legacyPackages.homeConfigurations = {
    #     common = homeConfiguration ../home-manager/common.nix;
    # } // lib.optionalAttrs (pkgs.hostPlatform.system == "x86_64-linux") {
    #   "logan@nijusan" = inputs.home-manager.lib.homeManagerConfiguration {
    #     inherit pkgs;
    #     modules = [
    #       {
    #         _module.args.self = self;
    #         _module.args.inputs = self.inputs;
    #         imports = [ ../home-manager/nijusan.nix ];
    #         home.username = "logan";
    #         home.homeDirectory = "/home/logan";
    #         home.packages = [ hm ];
    #       }
    #     ];
    #   };
    # };

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
      # apps.hm.program = "${hm}/bin/hm";
      packages.hm = hm;
    }
  );
}
