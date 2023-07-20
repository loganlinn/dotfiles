{ config
, flake-parts-lib
, lib
, ...
}:

with lib;

let
  my = (import ../lib/extended.nix lib).my;

  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption
    ({ options, config, pkgs, ... }: {
      options.my = {

        name = mkOption {
          type = types.str;
          default = "Logan";
        };

        user = mkOption {
          type = types.str;
          default = "logan";
        };

        email = mkOption {
          type = types.str;
          default = "logan@loganlinn.com";
        };

        website = mkOption {
          type = types.str;
          default = "https://loganlinn.com";
        };

        github.user = mkOption {
          type = types.str;
          default = "loganlinn";
        };

        github.oauth-token = mkOption {
          type = with types; nullOr str;
          default = null;
        };

        publicKeys = mkOption {
          type = types.listOf my.types.publicKeySubmodule;
          example = literalExpression ''
            [ { source = ./pubkeys.txt; } ]
          '';
          default = [ ];
          description = ''
            A list of public keys to be imported into GnuPG. Note, these key files
            will be copied into the world-readable Nix store.
          '';
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

        srcDir = mkOption {
          type = types.str;
          default = "${config.my.homeDir}/src";
        };

        # menus =
        #   let
        #     commandSubmodule = types.submodule {
        #       options = {
        #         description = mkOption {
        #           type = types.nullOr types.str;
        #           description = lib.mdDoc ''
        #             A description of what this program does.
        #           '';
        #           default = null;
        #         };
        #         exec = mkOption {
        #           type = types.oneOf [ types.str types.package ];
        #           description = lib.mdDoc ''
        #             The script or package to run

        #             The $FLAKE_ROOT environment variable will be set to the
        #             project root, as determined by the github:srid/flake-root
        #             module.
        #           '';
        #         };
        #       };
        #     };
        #     menuSubmodule = types.submodule {
        #       options = {
        #         description = mkOption {
        #           type = types.nullOr types.str;
        #           description = lib.mdDoc ''
        #             A description of what this menu does.
        #           '';
        #           default = null;
        #         };
        #         commands = mkOption {
        #           type = commandSubmodule;
        #         };
        #       };
        #     };
        #   in
        #   mkOption {
        #     type = types.attrsOf menuSubmodule;
        #     default = { };
        #   };
      };
    });
}
