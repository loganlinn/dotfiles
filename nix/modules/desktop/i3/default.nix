{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.i3;
in {
  imports = [./systemd.nix ./i3.nix];

  options.modules.desktop.i3 = {
    enable = mkEnableOption "i3 window manager";
  };

  config = mkIf cfg.enable {
    xsession.enable = true;

    xsession.windowManager.i3.enable = true;

    home.packages = with pkgs;
      [
        i3-layout-manager
        (writeShellApplication {
            name = "i3-shmlog";
            text = ''
              # temporarily enable i3 debug logging and stream to stdout

              i3-msg -q shmlog on
              trap 'i3-msg -q shmlog off' EXIT
              i3-dump-log -f
            '';
          })

        (writeShellApplication {
          name = "i3-dump-config";
          runtimeInputs = [ config.programs.jq.package or pkgs.jq ];
          text = ''
            i3-msg --raw --type get_config | jq -r '.included_configs[] | .variable_replaced_contents'
          '';
        })
      ]
      ++ (
        # Create shell script for each i3-msg message type
        # i.e. i3-config, i3-marks, i3-outputs, i3-tree, i3-workspaces
        forEach ["config" "marks" "outputs" "tree" "workspaces"] (type:
          writeShellApplication {
            name = "i3-${type}";
            runtimeInputs = [];
            text = ''
              exec i3-msg -t get_${type} "$@"
            '';
          })
      );
  };
}
