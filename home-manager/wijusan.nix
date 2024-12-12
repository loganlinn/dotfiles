{
  self,
  inputs,
  config,
  pkgs,
  lib,
  nix-colors,
  ...
}:

{
  imports = [
    self.homeModules.common
    self.homeModules.nix-colors
    self.homeModules.secrets
    ../nix/home/dev/lua.nix
    ../nix/home/dev/nix.nix
    ../nix/home/dev/nodejs.nix
    ../nix/home/dev/shell.nix
    ../nix/home/emacs
    ../nix/home/home-manager.nix
    ../nix/home/nixvim
    ../nix/home/pretty.nix
    ../nix/home/python
    ../nix/home/yt-dlp.nix
    ../nix/modules/spellcheck.nix
  ];

  colorScheme = nix-colors.colorSchemes.doom-one; # needed?

  # my.java.package = pkgs.jdk17;
  # my.java.toolchains = with pkgs; [ jdk8 jdk11 ];
  modules.spellcheck.enable = true;

  services.emacs = {
    enable = true;
    client.enable = true; # Generates .desktop file
  };

  # Configure Git to use ssh.exe (1Password agent forwarding)
  # https://developer.1password.com/docs/ssh/integrations/wsl/
  programs.git.extraConfig = {
    user.signingKey = config.my.pubkeys.ssh.ed25519;
    gpg.format = "ssh";
    gpg.ssh.program = "/mnt/c/Users/logan/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
    commit.gpgsign = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk; # native Wayland support
  };

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
  };

  programs.zsh = {
    dirHashes = {
      win = "/mnt/c/Users/logan"; # i.e. wslpath "$(wslvar HOMEPATH)"
      AppData = "/mnt/c/Users/logan/AppData/Roaming"; # i.e. wslpath "$(wslvar AppData)"
    };

    envExtra = ''
      # Ensure environment is configured with ~/.nix-profile,
      # otherwise $PATH et. al. aren't same for shell interactive modes.
      # https://github.com/NixOS/nix/issues/2587
      # https://github.com/NixOS/nix/issues/4376
      if [ -e /etc/profile.d/nix.sh ]; then
        . /etc/profile.d/nix.sh
      fi
    '';
  };

  programs.xplr = {
    enable = true;
    plugins = {
      wl-clipboard = pkgs.fetchFromGitHub {
        owner = "sayanarijit";
        repo = "wl-clipboard.xplr";
        rev = "a3ffc87460c5c7f560bffea689487ae14b36d9c3";
        hash = "sha256-I4rh5Zks9hiXozBiPDuRdHwW5I7ppzEpQNtirY0Lcks=";
      };
      ctx4 = pkgs.fetchFromGitHub {
        owner = "doums";
        repo = "ctx4.xplr";
        rev = "0670c9c365d665f923a6fd4b508fbb61abd50a0e";
        hash = "sha256-E3w00Mms5UPlvleB3yi7F2wwc7aBeTj3ACNkpDcgyAQ=";
      };
    };
    extraConfig = ''
      require("wl-clipboard").setup {
        copy_command = "wl-copy -t text/uri-list",
        paste_command = "wl-paste",
        keep_selection = true,
      }
    '';
  };

  xdg.enable = true;
  xdg.mimeApps.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = [ "*" ];

  home.packages = with pkgs; [
    wslu
    trashy
    micromamba
    socat # used with npiperelay.exe for access to named pipes in WSL
    nettools # i.e. `ifconfig` (`ip`, you're cool too)
    wl-clipboard
    tomb
  ];

  home.sessionVariables = {
    XDG_MUSIC_DIR = "/mnt/c/Users/logan/Music";
    ENTR_INOTIFY_WORKAROUND = "1"; # https://github.com/eradman/entr?tab=readme-ov-file#docker-and-wsl
  };

  home.username = "logan";
  home.homeDirectory = "/home/logan";
  home.stateVersion = "22.11";

  nix.enable = true;
  nix.package = pkgs.nixVersions.stable;
  nix.settings = {
    trusted-users = [
      "root"
      config.home.username
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
    accept-flake-config = true;
    run-diff-hook = true;
    show-trace = true;
  };
}
