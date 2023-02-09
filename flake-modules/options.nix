{ config, self, inputs, flake-parts-lib, lib, options, getSystem, extendModules, ... }:
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
  inherit (builtins)
    removeAttrs
    ;

in

{
  options = with types; {
    user = {
      name = mkOption {
        type = str;
        default = "logan";
      };

      home = mkOption {
        type = str;
        default = "/home/${config.user.name}";
      };

      packages = mkOption {
        types = listOf package;
        default = [ ];
      };
    };

    dotfiles = {
      repository = mkOption {
        type = types.str;
        default = "https://github.com/loganlinn/.dotfiles";
      };

      directory = mkOption {
        type = types.str;
        default = "${config.user.home}/.dotfiles";
      };
    };
  };
}
