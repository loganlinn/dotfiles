{ inputs', self, config, lib, pkgs, system, ... }:

with lib;

let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
  cfg = config.my.hyprland;
in {
  options.my.hyprland = { enable = mkEnableOption "Hyprland"; };

  # config = {
  config = mkIf cfg.enable {
    # assertions = [{
    #   assertion = length device.monitors > 0;
    #   message = ''
    #     At least one monitor in the `config.modules.device.monitors` is
    #     needed to use Hyprland module.
    #   '';
    # }];
    programs.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
      enableNvidiaPatches = true;
      xwayland.enable = true;
    };

    # hardware.graphics = {
    #   package = pkgs-unstable.mesa.drivers;
    #   driSupport32Bit = true; # if you also want 32-bit support (e.g for Steam)
    #   package32 = pkgs.pkgsi686Linux.mesa.drivers;
    # };

    # services.xserver.enable = false;
    services.greetd.enable = true;
    services.greetd.settings = {
      initial_session = { command = getExe hyprland; };
      default_session = {
        command =
          "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${getExe hyprland}";
      };
    };

    # home-manager.users.${config.my.user.name} = { config, lib, pkgs, ... }: {
    #   imports = [ inputs.hyprland.homeManagerModules.default ];

    #   # xdg.configFile."hypr/wallpapers".source = ./wallpapers;
    #   # xdg.configFile."hypr/sounds".source = ./sounds;
    #   # xdg.configFile."hypr/configs".source = ./configs;

    #   wayland.windowManager.hyprland = {
    #     enable = true;
    #     # extraConfig = import ./config.nix { inherit lib device pkgs; };
    #   };

    #   home.packages = with pkgs; [ grim slurp ];
    # };
  };
}
