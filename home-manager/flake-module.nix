{ self, inputs, withSystem, ... }:

{
  perSystem = { pkgs, lib, ... }:
    let
      username = "logan";

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
        text = builtins.readFile ./hm.sh;
      };

      homeConfiguration = module:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            {
              _module.args.self = self;
              _module.args.inputs = self.inputs;

              imports = [
                ../nix/modules
                module
              ];

              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.packages = [ hm ];
              home.sessionVariables.HM_CONFIG = "${toString module}";
              home.stateVersion = "22.11";
            }
          ];
        };

    in
    {
      apps.hm = {
        type = "app";
        program = "${hm}/bin/hm";
      };

      legacyPackages = {
        homeConfigurations = {
          common = homeConfiguration ./common.nix;

          "logan@nijusan" = withSystem "x86_64-linux" (_: homeConfiguration ./desktop);

          # framework = withSystem "x86_64-linux" (ctx@{ pkgs, ... }:
          #   homeConfiguration {
          #     extraModules = [./framework.nix];
          #   }
          # );

        };

      };
    };
}
