toplevel@{ self, inputs, lib, ... }:

{
  perSystem = ctx@{ options, config, self', inputs', pkgs, system, ... }: {
        
    legacyPackages.homeConfigurations = lib.optionalAttrs (system == "x86_64-linux") {

      "logan@nijusan" = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              inputs.nix-colors.homeManagerModule
              ../home-manager/common.nix
              {
                _module.args.self = self;
                _module.args.inputs = inputs;

                imports =  [
                  ../home-manager/common.nix
                  ../home-manager/nijusan.nix
                ];

                home.username = "logan";
                home.homeDirectory = "/home/logan";
                home.packages = config.my.user.packages;
              }
            ];

            extraSpecialArgs = {
              inherit (inputs)
                home-manager
                darwin
                emacs
                nix-colors
                fzf-git;
            };
          };

      # "logan@nijusan" = homeManagerConfiguration "x86_64-linux" ../home-manager/nijusan.nix;
      # "logan@framework" = homeManagerConfiguration "x86_64-linux" ../home-manager/framework.nix;
    };
  };
}
