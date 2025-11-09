{
  config,
  self,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.kitty;
  brewPrefix = config.homebrew.brewPrefix;
in {
  options.modules.kitty = {
    enable = lib.mkEnableOption "kitty";
  };

  config = lib.mkIf cfg.enable {
    homebrew.casks = ["kitty"];

    home-manager.users.${config.my.user.name} = {
      options,
      pkgs,
      lib,
      ...
    }: {
      imports = [
        ../../../nix/home/kitty
      ];

      programs.kitty = {
        enable = true;
        package = pkgs.writeShellScriptBin "kitty" ''exec "${brewPrefix}/kitty" "$@"'';
      };
    };
  };
}
