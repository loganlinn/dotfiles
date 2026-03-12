# {
#   config,
#   pkgs,
#   lib,
#   ...
# }:
# with lib;
# let
#   cfg = config.services.kanata-tray;
#   toml = pkgs.formats.toml { };
#   inherit (config.homebrew) brewPrefix;
#   pathStr = with types; coercedTo path toString str;
#   kanataTrayConfig =
#     toml.generate "kanata-tray" {
#       "$schema" = "https://raw.githubusercontent.com/rszyma/kanata-tray/main/doc/config_schema.json";
#     }
#     // cfg.settings;
# in
{
  # options.services.kanata-tray = {
  #   enable = mkEnableOption "kanata-tray";
  #   settings = mkOptions {
  #     type = types.submodule {
  #       options = {
  #         general.allow_concurrent_presets = mkOption {
  #           type = types.bool;
  #           default = false;
  #         };
  #         defaults.kanata_executable = mkOption {
  #           type = pathStr;
  #           default = "${brewPrefix}/bin/kanata";
  #         };
  #         defaults.hooks.pre_start = mkOption {
  #           type = types.listOf types.str;
  #           default = [ ];
  #         };
  #         defaults.hooks.post_start = mkOption {
  #           type = types.listOf types.str;
  #           default = [ ];
  #         };
  #         defaults.hooks.post_start_async = mkOption {
  #           type = types.listOf types.str;
  #           default = [ ];
  #         };
  #         defaults.hooks.post_stop = mkOption {
  #           type = types.listOf types.str;
  #           default = [ ];
  #         };
  #       };
  #       freeFormType = toml.type;
  #     };
  #   };
  # };
  # config = mkIf cfg.enable { };
}
