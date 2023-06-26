{ nix-colors
, config
, pkgs
, lib
, system
, ...
}:
let
  inherit (nix-colors.lib.contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    nix-colors.homeManagerModule
    ../nix
    ../nix/home/common.nix
    ../nix/home/dev # TODO module
    #../nix/home/dev/vala.nix
    ../nix/home/emacs.nix
    ../nix/home/home-manager.nix
    ../nix/home/kitty
    ../nix/home/mpd.nix
    ../nix/home/mpv.nix
    ../nix/home/nnn.nix
    ../nix/home/pretty.nix
    ../nix/home/ssh.nix
    ../nix/home/sync.nix
    ../nix/home/urxvt.nix
    ../nix/home/vpn.nix
    ../nix/home/vscode.nix
    ../nix/home/x11.nix
    ../nix/home/yt-dlp.nix
    ../nix/home/yubikey.nix
    ../nix/modules/programs/eww
    ../nix/modules/programs/the-way
    ../nix/modules/services
    ../nix/modules/spellcheck.nix
    ../nix/modules/fonts.nix
    ../nix/modules/desktop
    ../nix/modules/desktop/browsers
    ../nix/modules/desktop/browsers/firefox.nix
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
    editor.exec = "doom run";
  };

  colorScheme = nix-colors.colorSchemes.doom-one;

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

  programs.google-chrome.enable = true;
  programs.firefox.enable = true;
  programs.librewolf.enable = true;
  programs.qutebrowser.enable = true;

  modules.desktop.browsers =
    let
      chrome = lib.getExe config.programs.google-chrome.package;
    in
    {
      default = "${chrome} '--profile-directory=Profile 1'"; # work
      alternate = "${chrome} '--profile-directory=Default'"; # personal
    };

  gtk.enable = true;

  programs.rofi.enable = true;

  programs.the-way = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = [
    ];
  };

  services.dunst.enable = true;

  services.polybar.enable = true;

  modules.polybar = {
    networks = [
      {
        interface = "eno3";
        interface-type = "wired";
      }
      {
        interface = "wlo1";
        interface-type = "wireless";
      }
    ];
  };

  services.picom.enable = true;

  services.betterlockscreen = {
    enable = true;
    arguments = [ "-w" "dim" ];
    inactiveInterval = 15; # minutes
  };

  services.easyeffects.enable = false; # causing glitching on twitch streams

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
    # audacity
    # btrfs-snap # https://github.com/jf647/btrfs-snap
    # nemo
    (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override { }))
    btrfs-progs
    dbeaver
    gcc
    google-cloud-sdk
    jetbrains.idea-community
    libreoffice
    minikube
    plantuml
    wordnet # English thesaurus backend (used by synosaurus.el)
  ];

  # TODO move into own module (maybe can reuse settings type from https://github.com/nix-community/home-manager/blob/master/modules/programs/vim.nix)
  xdg.configFile."ideavim/ideavimrc".text = ''
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'

    packadd matchit

    set hlsearch
    set ignorecase
    set incsearch
    set smartcase
    set relativenumber

    " use system clipboard
    set clipboard+=unnamed

    " enable native IntelliJ insertion
    set clipboard+=ideaput

    " see https://github.com/JetBrains/ideavim/wiki/ideajoin-examples
    set ideajoin

    set idearefactormode=keep


    map <leader>f <Action>(GotoFile)
    map <leader>g <Action>(FindInPath)
    map <leader>b <Action>(Switcher)
  '';

  home.username = "logan";

  home.homeDirectory = "/home/logan";

  home.stateVersion = "22.11";
}
