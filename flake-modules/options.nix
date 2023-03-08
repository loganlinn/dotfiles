{ config, self, inputs, flake-parts-lib, lib, getSystem, extendModules, ... }:

with builtins;

let
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
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
in

{
  options = {

    perSystem = mkPerSystemOption ({ options, config, pkgs, ... }: {

      # imports = [
      #   (lib.mkAliasOptionModule [ "mission-control" "scripts" ])
      # ];

      options.my = {

        user = mkOption {
          type = types.str;
          default = "logan";
        };

        email = mkOption {
          type = types.str;
          default = "logan@llinn.dev";
        };

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
          default =
            if pkgs.stdenv.targetPlatform.isLinux
            then "/home/${config.my.user}"
            else "/Users/${config.my.user}";
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


      # config = {
      #   home-manager.users.${config.my.user} = mkAliasDefinitions options.my.home;
      # };

    });
  };
}
