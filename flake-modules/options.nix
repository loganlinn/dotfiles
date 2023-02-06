{ config, self, flake-parts-lib, lib, options, getSystem, extendModules, ... }:
let
  inherit (lib)
    pipe
    genAttrs
    mapAttrs
    mkIf
    mkOption
    optionalAttrs
    types
    removePrefix
    ;
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
  inherit (builtins)
    removeAttrs
    ;

in

{
  options = {
    user = {
      username = mkOption {
        type = types.str;
        default = "logan";
      };

      home = mkOption {
        type = types.str;
        default = "/home/${config.user.username}";
      };

      dotfiles = {
        repository = mkOption {
          type = types.str;
          default = "https://github.com/loganlinn/.dotfiles";
        };

        directory = mkOption {
          type = types.str;
          default = toString ./.;
        };

      };
      #   (removePrefix "/mnt"
      #     (findFirst pathExists (toString ../.) [
      #       "/home/${options.user}"
      #       "/mnt/etc/dotfiles"
      #       "/etc/dotfiles"
      #     ]));

    };

  };

}
