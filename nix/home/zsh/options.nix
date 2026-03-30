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
    functions = mkOption {
      type = with types; attrsOf str;
      default = { };
    };
  };

  config = {
    programs.zsh = {
      initContent = ''
        ${concatLines (mapAttrsToList (name: value: ''bindkey -s '${name}' '${value}'') cfg.bindkeys)}

        fpath=("${config.xdg.dataHome}/zsh/functions" $fpath)
        local -a _zfuncs=($fpath[1]/*(N:t))
        (( $#_zfuncs )) && autoload -U "$_zfuncs[@]"
      '';
    };

    xdg.dataFile = mapAttrs' (
      name: text:
      (nameValuePair "zsh/functions/${name}" {
        executable = false;
        text = ''
          # function ${name} {
          emulate -L zsh
          ${text}
          # }
          # vim: ft=zsh
        '';
      })
    ) cfg.functions;
  };
}
