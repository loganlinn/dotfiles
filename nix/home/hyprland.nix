{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.hyprland;
in {
  imports = optional cfg.enable inputs.hyprland.homeManagerModules.default;

  options.my.hyprland = {
    enable = mkEnableOption "hyprland";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      enableNvidiaPatches = true;
      recommendedEnvironment = true;
      plugins = [
        # flake.inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
      ];
      extraConfig = ''
        # https://wiki.hyprland.org/Nvidia/
        # env = LIBVA_DRIVER_NAME,nvidia
        # env = XDG_SESSION_TYPE,wayland
        # env = GBM_BACKEND,nvidia-drm
        # env = __GLX_VENDOR_LIBRARY_NAME,nvidia
        # env = WLR_NO_HARDWARE_CURSORS,1

        $mod = SUPER

        # workspaces
        ${concatStringsSep "\n" (genList (x: let
          ws = let c = (x + 1) / 10; in toString (x + 1 - (c * 10));
        in ''
          bind = $mod, ${ws}, workspace, ${toString (x + 1)}
          bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        '') 10)}
      '';
    };
  };
}
