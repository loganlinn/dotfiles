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
  options = {
    user = {
      name = mkOption {
        type = types.str;
        default = "logan";
      };

      home = mkOption {
        type = types.str;
        default = "/home/${config.user.user}";
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

  config = { };
}
