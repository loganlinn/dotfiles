{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.modules.desktop.i3;

in
{
  imports = [ ./systemd.nix ./i3.nix ];

  options.modules.desktop.i3 = {
    enable = mkEnableOption "i3 window manager";
  };

  config = mkIf cfg.enable {

    xsession.enable = true;

    xsession.windowManager.i3.enable = true;

    home.packages = with pkgs; [
      i3-layout-manager

      (with pkgs; python3Packages.buildPythonPackage rec {
        pname = "i3-balance-workspace"; # bin/i3_balance_workspace
        version = "1.8.6";
        format = "pyproject";
        nativeBuildInputs = [ poetry python3Packages.poetry-core ];
        propagatedBuildInputs = with python3.pkgs; [ i3ipc ];
        src = python3Packages.fetchPypi {
          inherit pname version;
          hash = "sha256-zJdn/Q6r60FQgfehtQfeDkmN0Rz3ZaqgNhiWvjyQFy0=";
        };
        doCheck = false;
        meta = {
          description = "Balance windows and workspaces in i3wm";
          homepage = "https://github.com/atreyasha/i3-balance-workspace";
          license = lib.licenses.mit;
        };
      })

      (writeShellApplication {
        name = "i3-next-workspace";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          function next_workspace_num() {
            local i=1
            while read -r ws; do
              if (( i != ws )); then
                echo $i
                return
              fi
              i=$((i+1))
            done < <(i3-msg -t get_workspaces | jq '.[] | .num')
            echo $i
          }

          ws="$(next_workspace_num)"
          case "$1" in
          focus) i3-msg "workspace number $ws" ;;
          move)  i3-msg "move container to workspace number $ws" ;;
          carry) i3-msg "move container to workspace number $ws, workspace number $ws" ;;
          *) echo "usage: $(basename "$0") <focus|move|carry>" >&2; exit 1 ;;
          esac

        '';
      })

    ] ++ (
      # Create shell script for each i3-msg message type
      # i.e. i3-config, i3-marks, i3-outputs, i3-tree, i3-workspaces
      forEach [ "config" "marks" "outputs" "tree" "workspaces" ] (type:
        writeShellApplication {
          name = "i3-${type}";
          runtimeInputs = [ ];
          text = ''
            exec i3-msg -t get_${type} "$@"
          '';
        })
    );
  };
}
