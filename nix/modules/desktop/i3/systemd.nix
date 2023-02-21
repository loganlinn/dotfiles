{ config, lib, pkgs, ... }:

# systemd integration for i3, polybar
#
# see:
# - https://github.com/nix-community/home-manager/issues/213
# - https://github.com/nix-community/home-manager/blob/5e889b385c43a8a72ada5ebc4888bbebb129b438/modules/services/window-managers/i3-sway/sway.nix#L472-L486
let
  inherit (lib) mkIf mkForce mkOption mkEnableOption types;

  cfg = config.modules.desktop.i3;

  sessionCommand = pkgs.writeShellScript "i3-session" ''
    set -eu

    # ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd I3SOCK DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
    systemctl --user set-environment I3SOCK=$(${config.xsession.windowManager.i3.package}/bin/i3 --get-socketpath)
    systemctl --user start i3-session.target
  '';

in
{
  options.modules.desktop.i3 = {
    systemdIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable <filename>i3-session.target</filename> on
        sway startup. This links to
        <filename>graphical-session.target</filename>.
        Some important environment variables will be imported to systemd
        and dbus user environment before reaching the target, including
        <itemizedlist>
          <listitem><para><literal>DISPLAY</literal></para></listitem>
          <listitem><para><literal>XDG_CURRENT_DESKTOP</literal></para></listitem>
        </itemizedlist>
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.systemdIntegration) {

    xsession.windowManager.i3.config.startup = [
      { command = "${sessionCommand}"; notification = false; }
    ];

    xsession.windowManager.i3.extraConfig = ''
    '';

    systemd.user.targets.i3-session = {
      Unit = {
        Description = "i3 window manager session";
        BindsTo = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
        # Wants = [ "graphical-session-pre.target" ];
        # After = [ "graphical-session-pre.target" ];
      };
    };

    systemd.user.services.polybar = mkIf config.services.polybar.enable {
      Unit.PartOf = mkForce [ "i3-session.target" ];
      Install.WantedBy = mkForce [ "i3-session.target" ];
    };

  };
}
