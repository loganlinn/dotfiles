toplevel@{ self, config, inputs, withSystem, lib, ... }:

let

  homeManagerConfiguration = system: modules: ctx@{ options, config, pkgs, system, ... }:
    lib.optionalAttrs (ctx.system == system)
      (inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = ctx.pkgs;
        modules = [
          inputs.nix-colors.homeManagerModule
          ../home-manager/common.nix
          {
            _module.args.self = self;
            _module.args.inputs = inputs;
            # _module.args.lib = ctx.lib.extend { my = self.lib; };

            imports = lib.toList modules;

            home.username = config.my.user.name;
            home.homeDirectory = config.my.user.home;
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
      });

in
{

  perSystem = ctx@{ options, config, self', inputs', pkgs, system, ... }: {

    legacyPackages.homeConfigurations = {
      "logan@nijusan" = homeManagerConfiguration "x86_64-linux" ../home-manager/nijusan.nix ctx;
      # "logan@framework" = homeManagerConfiguration "x86_64-linux" ../home-manager/framework.nix ctx;
    };

  };
}
