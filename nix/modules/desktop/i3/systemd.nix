{ config, lib, pkgs, ... }:

# systemd integration for i3, polybar
#
# see:
# - https://github.com/nix-community/home-manager/issues/213
# - https://github.com/nix-community/home-manager/blob/5e889b385c43a8a72ada5ebc4888bbebb129b438/modules/services/window-managers/i3-sway/sway.nix#L472-L486
let
  inherit (lib) mkIf mkForce mkOption mkEnableOption types;

  sessionCommand = pkgs.writeShellScript "i3-session" ''
    set -eu

    # ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd I3SOCK DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
    systemctl --user set-environment I3SOCK=$(${config.xsession.windowManager.i3.package}/bin/i3 --get-socketpath)
    systemctl --user start i3-session.target
  '';

in
{
  # WIP
  # config = {

  #   xsession.windowManager.i3.config.startup = [
  #     { command = "${sessionCommand}"; notification = false; }
  #   ];

  #   xsession.windowManager.i3.extraConfig = ''
  #   '';

  #   systemd.user.targets.i3-session = {
  #     Unit = {
  #       Description = "i3 session";
  #       Documentation = [ "man:systemd.special(7)" ];
  #       BindsTo = [ "graphical-session.target" ];
  #       Wants = [ "graphical-session-pre.target" ];
  #       After = [ "graphical-session-pre.target" ];
  #     };
  #   };

  #   systemd.user.services.polybar = mkIf config.services.polybar.enable {
  #     Unit.PartOf = mkForce [ "i3-session.target" ];
  #     Install.WantedBy = mkForce [ "i3-session.target" ];
  #   };

  # };
}
