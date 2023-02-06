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
    text = builtins.readFile ../home-manager/hm.sh;
  };

  withHomeConfiguration =
    { name
    , system ? "x86_64-linux"
    , extraModules ? [ ]
    }: {
      legacyPackages.homeManagerConfiguration.${name} = withSystem system
        ({ pkgs, lib, ... }: inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            {
              _module.args.self = self;
              _module.args.inputs = self.inputs;
              imports = [ ../home-manager/common.nix ] ++ (lib.toList extraModules);
            }
            ({ config, ... }: {
              home.username = "logan";
              home.homeDirectory = "/home/logan";
              home.sessionVariables = {
                FLAKE_CONFIG_URI = "~/.dotfiles#${name}";
              };
            })
          ];
        });
    };

in
{
  perSystem = { config, pkgs, lib, inputs', ... }:
    let hm = hmFor pkgs; in
    {
      apps.hm.program = "${hm}/bin/hm";

      legacyPackages.homeConfigurations = {

        common = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            {
              _module.args.self = self;
              _module.args.inputs = self.inputs;
              imports = [ ../home-manager/common.nix ];
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
              imports = [ ../home-manager/nijusan.nix ];
              home.username = "logan";
              home.homeDirectory = "/home/logan";
              home.packages = [ hm ];
              home.stateVersion = "22.11";
            }
          ];
        };

        # TODO port
        # homeConfigurations." logan@framework" = home-manager.lib.homeManagerConfiguration {
        #   pkgs = pkgs."x86_64-linux";
        #   modules = [
        #     # ./nix/modules
        #     # ./nix/home/framework.nix
        #     ./nix/hosts/framework/home.nix
        #   ];
        #   extraSpecialArgs = { unstable = pkgs'."x86_64-linux"; };
        # };

      };
    };
}
