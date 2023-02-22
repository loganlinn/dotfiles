{ config, pkgs, lib, nix-colors, ... }:

let
  inherit (nix-colors.lib-contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    ../nix
    ../nix/home/common.nix
    ../nix/home/dev # TODO module
    ../nix/home/emacs.nix # TODO module
    ../nix/home/kitty
    ../nix/home/mpv.nix
    ../nix/home/nnn.nix
    ../nix/home/pretty.nix
    ../nix/home/sync.nix
    ../nix/home/urxvt.nix
    ../nix/home/vpn.nix
    ../nix/home/vscode.nix
    ../nix/home/zsh
    ../nix/modules/programs/eww
    ../nix/modules/programs/the-way
    ../nix/modules/services
    ../nix/modules/spellcheck.nix
    ../nix/modules/fonts.nix
    ../nix/modules/desktop
    ../nix/modules/desktop/browsers
    ../nix/modules/desktop/i3
  ];

  sops.defaultSopsFile = ../secrets/default.yaml;
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  sops.secrets.github_token.sopsFile = ../secrets/default.yaml;

  modules.fonts.enable = true;

  modules.spellcheck.enable = true;

  modules.desktop.i3.enable = true;

  modules.polybar = {
    enable = true;
    networks = [
      { interface = "eno3"; interface-type = "wired"; }
      { interface = "wlo1"; interface-type = "wireless"; }
    ];
    top.center.modules = [ "title" ];
    top.right.modules = [
      "memory"
      "cpu"
      "temperature"
      "sep4"
      "pulseaudio"
      "sep3"
      "dunst"
      "network-eno3"
      "network-wlo1"
      "sep1"
      "date"
    ];
  };

  modules.theme = {
    active = "arc";

    # wallpaper = ../wallpaper/wallhaven-weq8y7.png;
    wallpaper = nixWallpaperFromScheme {
      scheme = config.colorscheme;
      width = 3840;
      height = 1600;
      logoScale = 4.0;
    };
  };

  programs.rofi.enable = true;

  programs.the-way = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  services.dunst.enable = true;

  services.picom.enable = true;

  # TODO define option for default browser
  home.sessionVariables.BROWSER = "${lib.getExe config.programs.google-chrome.package}";

  gtk.enable = true;

  # qt.enable = true;

  home.packages = with pkgs; [
    btrfs-progs
    google-cloud-sdk
    # nemo
    minikube
  ];

  home.stateVersion = "22.11";
}
