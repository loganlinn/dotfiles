{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  options = {
    programs.podman-desktop.enable = mkEnableOption "podman-desktop";
  };

  config = mkIf config.programs.podman-desktop.enable {
    assertions = [
      {
        assertion = config.homebrew.enable;
        message = "homebrew must be enabled for podman-desktop";
      }
    ];
    homebrew.brews = [
      "podman-compose"
    ];
    homebrew.casks = [
      "podman-desktop"
    ];
    environment.systemPath = [
      "/opt/podman/bin" # podman toolchain installed via podman-desktop
    ];
    # environment.systemPackages = with pkgs; [
    #   podman
    # ];
  };
}
