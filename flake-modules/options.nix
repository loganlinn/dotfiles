{ config, self, inputs, flake-parts-lib, lib, getSystem, extendModules, ... }:
with builtins;
let
  inherit (lib)
    genAttrs
    mapAttrs
    mkIf
    mkOption
    optionalAttrs
    removePrefix
    types
    mkAliasDefinitions
    ;
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
in

{
  options = {

    # my.systems = mkOption {
    #   type = with types; attrsOf (types.submodule {
    #     system = mkOption {
    #       type = str;
    #     };
    #   });
    # };

    perSystem = mkPerSystemOption
      ({ options, config, pkgs, ... }: {

        options = {

          my = {
            user = mkOption {
              type = types.str;
              default = "logan";
            };

            email = mkOption {
              type = types.str;
              default = "logan@llinn.dev";
            };

            # home = mkOption {
            #   type = options.home-manager.users.type.functor.wrapped;
            # };

            github.user = mkOption {
              type = types.str;
              default = "loganlinn";
            };

            github.oauth-token = mkOption {
              type = with types; nullOr str;
              default = null;
            };

            homeDir = mkOption {
              type = types.str;
              default = "/home/${config.my.username}"; # TODO if isDarwin then "/Users" else "/home"
            };

            dotfilesDir = mkOption {
              type = types.str;
              default = "${config.my.homeDir}/.dotfiles";
            };

            defaults.terminal = mkOption {
              type = with types; oneOf [ path str package ];
              default = "${pkgs.kitty}/bin/kitty";
              apply = toString;
            };

            defaults.explorer = mkOption {
              type = with types; oneOf [ path str package ];
            };

            # TODO public keys
          };

        };

        # config = {
        #   home-manager.users.${config.my.user} = mkAliasDefinitions options.my.home;
        # };

      });
  };
}
