{ flake, config, pkgs, lib, system, ... }:

let
  inherit (flake.inputs) nix-colors;
  inherit (nix-colors.lib-contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    ./autorandr.nix
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

  modules.desktop.i3 = {
    enable = true;
  };

  modules.polybar = {
    enable = true;
    networks = [
      { interface = "eno3"; interface-type = "wired"; }
      { interface = "wlo1"; interface-type = "wireless"; }
    ];
    top.left.modules = [ "title" ];
    top.center.modules = [ "i3" "sep1" "i3-scratchpad" ];
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

  gtk.enable = true;

  programs.rofi.enable = true;

  programs.the-way = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.obs-studio.enable = true;

  services.dunst.enable = true;

  services.picom.enable = true;

  home.sessionVariables = {
    BROWSER = "${lib.getExe config.programs.google-chrome.package}"; # TODO use option
  };

  #
  #    $ xrandr --query | grep " connected"
  #    DP-0 connected primary 3840x1600+2560+985 (normal left inverted right x axis y axis) 880mm x 367mm
  #
  #    # given, 24.5 mm per inch
  #    $ bc
  #    3880/(880/24.5)
  #    110
  #    1600/(367/24.5)
  #    114

  xresources.properties."Xft.dpi" = "96";

  # services.emanote = {
  #   enable = true;
  #   notes = [
  #     "${config.home.homeDirectory}/Sync/Notes"
  #   ];
  #   package = flake.inputs.emanote.packages.${system}.default;
  # };

  # pkgs.fetchFromGitHub {
  #   owner = "kdave";
  #   repo = "btrfsmaintenance";
  #   rev = "be42cb6267055d125994abd6927cf3a26deab74c";
  #   hash = "sha256-wD9AWOaYtCZqU2YIxO6vEDIHCNQBygvFzRHW3LOQRqk=";
  # };

  # Install a JSON formatted list of all Home Manager options. This can be located at <profile directory>/share/doc/
  # home-manager/options.json, and may be used for navigating definitions, auto-completing, and other miscellaneous tasks.
  manual.json.enable = true;

  home.packages = with pkgs; [
    btrfs-progs
    # btrfs-snap # https://github.com/jf647/btrfs-snap
    jetbrains.idea-community
    dbeaver
    google-cloud-sdk
    # nemo
    minikube
    (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
  ];

  # use system clipboard
  home.file.".ideavim".text = ''
    set clipboard+=unnamed
  '';

  home.username = "logan";

  home.homeDirectory = "/home/logan";

  home.stateVersion = "22.11";
}
