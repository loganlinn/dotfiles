{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.uvTools;
  uv = "${config.programs.uv.package}/bin/uv";
in
{
  options.my.uvTools = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Package names to install as uv tools via `uv tool install`.";
  };

  config = lib.mkIf (cfg != []) {
    programs.uv.enable = true;

    home.activation.uvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for pkg in ${lib.concatStringsSep " " cfg}; do
        if ! ${uv} tool list 2>/dev/null | grep -q "^$pkg "; then
          run ${uv} tool install "$pkg"
        fi
      done
    '';
  };
}
