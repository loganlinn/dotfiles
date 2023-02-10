{ config, self, inputs, flake-parts-lib, lib, getSystem, extendModules, ... }:
let
  inherit (lib)
    genAttrs
    mapAttrs
    mkIf
    mkOption
    optionalAttrs
    removePrefix
    types
    ;
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
in

{
  options = {

    my.systems = mkOption {
      type = with types; attrsOf (types.submodule {
        system = mkOption {
          type = str;
        };
      });
    };


    perSystem = mkPerSystemOption ({ config, pkgs, ... }: {

      options = {

        my.user = {
          name = mkOption {
            type = types.str;
            default = "logan";
          };

          home = mkOption {
            type = types.str;
            default = "/home/${config.my.user.name}";
          };

          packages = mkOption {
            type = with types; listOf package;
            default = [ ];
          };

          email = mkOption {
            type = types.str;
            default = "logan@llinn.dev";
          };

          github = mkOption {
            type = types.str;
            default = "loganlinn";
          };

          # TODO public keys
        };

        my.systemPackages = mkOption {
          type = with types; listOf package;
          default = [ ];
        };

      };
    });
  };
}
