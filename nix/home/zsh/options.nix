{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.zsh;
in
{
  options.my.zsh = {
    bindkeys = mkOption {
      description = "in-string -> out-string";
      type = types.attrsOf types.str;
      default = { };
    };
  };

  config = {
    programs.zsh.initContent = ''
      ${concatLines (mapAttrsToList (name: value: ''bindkey -s '${name}' '${value}'') cfg.bindkeys)}
    '';
  };
}
