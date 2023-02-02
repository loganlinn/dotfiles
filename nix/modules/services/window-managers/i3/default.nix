{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.xsession.windowManager.i3;

  i3-draw = import ./i3-draw.nix { inherit pkgs; };

  # Create shell script for each i3-msg message type
  # i.e. `i3-config`, `i3-marks`, `i3-outputs`, etc
  i3-utils = let types = [ "config" "marks" "outputs" "tree" "workspaces" ]; in
    map
      (type: pkgs.writeShellApplication {
        name = "i3-${type}";
        runtimeInputs = [ cfg.package ];
        text = ''
          exec i3-msg -t get_${type} "$@"
        '';
      })
      types;
in
{
  # options.xsession.windowManager.i3 = { };

  config = mkIf cfg.enable {
    xsession.windowManager.i3 = mkOptionDefault {
      config = import ./i3-config.nix {
        inherit config lib pkgs;
      };
    };

    home.packages = with pkgs; [
      i3-draw
      xdotool
    ] ++ i3-utils;
  };
}
