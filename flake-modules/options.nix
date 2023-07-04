{ config
, flake-parts-lib
, lib
, ...
}:
with builtins; let
  inherit
    (flake-parts-lib)
    mkPerSystemOption
    ;

  inherit
    (lib)
    genAttrs
    mapAttrs
    mkIf
    mkOption
    optionalAttrs
    removePrefix
    types
    mkAliasDefinitions
    ;

  strOrPackage = with lib; let
    resolveKey = key:
      let
        attrs = builtins.filter builtins.isString (builtins.split "\\." key);
        op = sum: attr: sum.${attr} or (throw "package \"${key}\" not found");
      in
      builtins.foldl' op pkgs attrs;
  in
  # Because we want to be able to push pure JSON-like data into the environment.
  types.coercedTo types.str resolveKey types.package;

  exeType = with lib; types.coercedTo types.package getExe types.str;
in
{
  options = {
    perSystem =
      mkPerSystemOption
        ({ options
         , config
         , pkgs
         , ...
         }: {
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
              default = "logan@loganlinn.com";
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

            # TODO public keys

            menus =
              let
                commandSubmodule = types.submodule {
                  options = {
                    description = mkOption {
                      type = types.nullOr types.str;
                      description = lib.mdDoc ''
                        A description of what this program does.
                      '';
                      default = null;
                    };
                    exec = mkOption {
                      type = types.oneOf [ types.str types.package ];
                      description = lib.mdDoc ''
                        The script or package to run

                        The $FLAKE_ROOT environment variable will be set to the
                        project root, as determined by the github:srid/flake-root
                        module.
                      '';
                    };
                  };
                };
                menuSubmodule = types.submodule {
                  options = {
                    description = mkOption {
                      type = types.nullOr types.str;
                      description = lib.mdDoc ''
                        A description of what this menu does.
                      '';
                      default = null;
                    };
                    commands = mkOption {
                      type = commandSubmodule;
                    };
                  };
                };
              in
              mkOption {
                type = types.attrsOf menuSubmodule;
                default = { };
              };
          };

          # config = {
          #   home-manager.users.${config.my.user} = mkAliasDefinitions options.my.home;
          # };
        });
  };
}
