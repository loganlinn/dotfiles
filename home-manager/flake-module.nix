{ self, inputs, withSystem, ... }:

let

  hmFor = pkgs: pkgs.writeShellApplication {
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

in
{
  perSystem = { config, pkgs, lib, inputs', ... }:
    let
      hm = hmFor pkgs;
    in
    {
      apps.hm.program = "${hm}/bin/hm";

      legacyPackages = {
        homeConfigurations = {

          common = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              {
                _module.args.self = self;
                _module.args.inputs = self.inputs;
                imports = [ ./common.nix ];
                home.username = "logan";
                home.homeDirectory = "/home/logan";
                home.packages = [ hm ];
              }
            ];
          };

        } // lib.optionalAttrs (pkgs.hostPlatform.system == "x86_64-linux") {

          "logan@nijusan" = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              {
                _module.args.self = self;
                _module.args.inputs = self.inputs;
                imports = [ ./nijusan.nix ];
                home.username = "logan";
                home.homeDirectory = "/home/logan";
                home.packages = [ hm ];
                home.stateVersion = "22.11";
              }
            ];
          };
        };
      };

      # devShells.default = inputs'.devshell.legacyPackages.mkShell {
      #   packages = [
      #     pkgs.alejandra
      #     pkgs.git
      #     config.packages.repl
      #   ];
      #   name = "dots";
      # };
    };

  flake = {
    legacyPackages = {
      homeConfigurations = {

        "logan@nijusan" = withSystem "x86_64-linux"
          ({ config, pkgs, ... }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                {
                  _module.args.self = self;
                  _module.args.inputs = self.inputs;
                  imports = [ ./nijusan.nix ];
                  home.username = "logan";
                  home.homeDirectory = "/home/logan";
                  home.packages = [ config.packages.hm ];
                  home.stateVersion = "22.11";
                }
              ];
            });

      };
    };
  };
}
