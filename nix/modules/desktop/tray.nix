{ lib, ... }: {
  # Required by syncthingtray.service, flameshot.service, etc.
  # https://github.com/nix-community/home-manager/issues/2064
  # systemd.user.targets.tray = lib.mkDefault {
  #   Unit = {
  #     Description = "Home Manager System Tray";
  #     Requires = ["graphical-session-pre.target"];
  #   };
  # };
}
