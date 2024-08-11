{ config, pkgs, lib, nix-colors, ... }:

{
  imports = [
    ../nix/home/dev/nix.nix
    ../nix/home/dev/nodejs.nix
    ../nix/home/dev/shell.nix
    ../nix/home/dev/lua.nix
    ../nix/home/python
    ../nix/home/emacs
    ../nix/home/home-manager.nix
    ../nix/home/pretty.nix
    ../nix/home/yt-dlp.nix
    ../nix/modules/spellcheck.nix
  ];

  colorScheme = nix-colors.colorSchemes.doom-one; # needed?

  my.astronvim.enable = false;
  # my.java.package = pkgs.jdk17;
  # my.java.toolchains = with pkgs; [ jdk8 jdk11 ];
  modules.spellcheck.enable = true;

  services.emacs.enable = true;
  services.emacs.client.enable = true; # Generates .desktop file
  # Configure Git to use ssh.exe (1Password agent forwarding)
  # https://developer.1password.com/docs/ssh/integrations/wsl/
  programs.git.extraConfig = {
    user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpyxX1xNYCJHLpTQAEorumej3kyNWlknnhQ/QqkhdN";
    gpg.format = "ssh";
    gpg.ssh.program = "/mnt/c/Users/logan/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
    commit.gpgsign = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk; # native Wayland support
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.zsh = {
    dirHashes = {
       win = "/mnt/c/Users/logan"; # i.e. wslpath "$(wslvar HOMEPATH)"
       AppData = "/mnt/c/Users/logan/AppData/Roaming"; # i.e. wslpath "$(wslvar AppData)" 
    };
  };


  home.packages = with pkgs; [
    wslu
    trashy
    micromamba
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
    trusted-users = [ "root" config.home.username ];
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    warn-dirty = false;
    accept-flake-config = true;
    run-diff-hook = true;
    show-trace = true;
  };
}
