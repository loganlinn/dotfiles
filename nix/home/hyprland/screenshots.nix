{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.wayland.windowManager.hyprland;

  screenshotDir = config.my.userDirs.screenshots;

  screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
    set -euo pipefail
    dir="${screenshotDir}"
    mkdir -p "$dir"
    filename="$dir/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"

    case "''${1:-region}" in
      region)
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | tee "$filename" | ${pkgs.wl-clipboard}/bin/wl-copy
        ;;
      window)
        geometry=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        ${pkgs.grim}/bin/grim -g "$geometry" - | tee "$filename" | ${pkgs.wl-clipboard}/bin/wl-copy
        ;;
      screen)
        ${pkgs.grim}/bin/grim - | tee "$filename" | ${pkgs.wl-clipboard}/bin/wl-copy
        ;;
      *)
        echo >&2 "Usage: screenshot [region|window|screen]"
        exit 1
        ;;
    esac

    ${pkgs.libnotify}/bin/notify-send -i "$filename" "Screenshot saved" "$filename"
  '';

  colorPickerScript = pkgs.writeShellScriptBin "color-picker" ''
    set -euo pipefail
    color=$(${pkgs.hyprpicker}/bin/hyprpicker -a)
    ${pkgs.libnotify}/bin/notify-send "Color picked" "$color copied to clipboard"
  '';
in {
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "screenshots module requires Linux";
      }
      {
        assertion = cfg.enable;
        message = "screenshots module requires Hyprland (Wayland)";
      }
    ];

    home.packages = [
      pkgs.grim
      pkgs.slurp
      pkgs.hyprpicker
      pkgs.wl-clipboard
      pkgs.libnotify
      screenshotScript
      colorPickerScript
    ];
  };
}
