{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hammerspoon;
  inherit (config) my;
in
{
  options = {
    hammerspoon = {
      enable = mkEnableOption "hammerspoon";
    };
  };
  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [ "hammerspoon" ];
    };

    home-manager.users.${my.user.name} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        inherit (config.lib.file) mkOutOfStoreSymlink;
        fetchSpoon =
          {
            name,
            rev,
            hash,
            owner ? "Hammerspoon",
            repo ? "Spoons",
          }:
          pkgs.fetchzip {
            url = "https://github.com/${owner}/${repo}/raw/${rev}/Spoons/${name}.spoon.zip";
            hash = hash;
          };
      in
      {
        home.activation.hammerspoonConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
          if ! [ -d ~/.hammerspoon ]; then
            run mkdir -p ~/.hammerspoon
          fi
          if ! [ -f ~/.hammerspoon/init.lua ]; then
            run ln -s "${config.my.flakeDirectory}/darwin/modules/hammerspoon/init.lua" ~/.hammerspoon/init.lua
          fi
        '';

        home.file = {
          ".hammerspoon/Spoons/EmmyLua.spoon".source = fetchSpoon {
            name = "EmmyLua";
            rev = "c12db871a179e6af29c1a290222aeb1ad9f34ffb";
            hash = "sha256-frXlZzV7soSDGpepiVT+EKe4Td5HtKp7/BL2uRBroPQ=";
          };

          ".hammerspoon/Spoons/LeftRightHotkey.spoon".source = fetchSpoon {
            name = "LeftRightHotkey";
            rev = "c12db871a179e6af29c1a290222aeb1ad9f34ffb";
            hash = "sha256-hGCFBEPosqOx6eT6gilFz2DPa/AYjq/TzqeHjiyI6NE=";
          };
        };
      };
  };
}
