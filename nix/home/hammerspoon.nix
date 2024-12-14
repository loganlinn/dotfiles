# HACKS!
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  cfg = config.programs.hammerspoon;
  applicationsDirectory = "${config.home.homeDirectory}/Applications";
  bundlePath = "${config.home.homeDirectory}/Applications/Nix Apps/Hammerspoon.app";
  frameworksPath = "${bundlePath}/Contents/Frameworks";
  resourcesPath = "${bundlePath}/Contents/Resources";
in
{
  options = {
    programs.hammerspoon = {
      enable = mkEnableOption "hammerspoon";
      version = mkOption {
        type = types.str;
        default = "1.0.0";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.fetchzip {
          url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${cfg.version}/Hammerspoon-${cfg.version}.zip";
          sha256 = "sha256-CuTFI9qXHplhWLeHS7bgZJolULbg9jQRyT6MTKzkQqs=";
          stripRoot = false;
        };
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file = {
      "Applications/Nix Apps/Hammerspoon.app".source = "${cfg.package}/Hammerspoon.app";
      ".hammerspoon".source = mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/hammerspoon";
      ".local/bin/hs".source = mkOutOfStoreSymlink "${frameworksPath}/hs/hs";
      ".local/share/man/man1/hs.1".source = mkOutOfStoreSymlink "${resourcesPath}/man/hs.man";
    };
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
  };
}
