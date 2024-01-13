{ self', config, pkgs, lib, nix-colors, ... }:

let inherit (nix-colors.lib.contrib { inherit pkgs; }) nixWallpaperFromScheme;

in {
  imports = [
    # ../nix/home/dev
    ../nix/home/dev/nodejs.nix
    ../nix/home/emacs
    ../nix/home/home-manager.nix
    ../nix/home/pretty.nix
    # ../nix/home/x11.nix
    # ../nix/home/yt-dlp.nix
    ../nix/modules/spellcheck.nix
  ];

  colorScheme = nix-colors.colorSchemes.doom-one; # nix-colors

  # my.java.package = pkgs.jdk17;
  # my.java.toolchains = with pkgs; [ jdk8 jdk11 ];

  modules.spellcheck.enable = true;

  # Configure Git to use ssh.exe (1Password agent forwarding)
  # https://developer.1password.com/docs/ssh/integrations/wsl/
  programs.git.extraConfig = {
    user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpyxX1xNYCJHLpTQAEorumej3kyNWlknnhQ/QqkhdN";
    gpg.format = "ssh";
    gpg.ssh.program = "/mnt/c/Users/logan/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
    commit.gpgsign = true;
  };

  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs-git;

  # programs.nix-index.enable = false;
  # programs.nix-index.enableZshIntegration = config.programs.nix-index.enable;

  home.packages = with pkgs; [
  ];

  home.username = "logan";
  home.homeDirectory = "/home/logan";
  home.stateVersion = "22.11";

  nix.enable = true;
  nix.package = pkgs.nixUnstable;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    warn-dirty = false;
    accept-flake-config = true;
    run-diff-hook = true;
    show-trace = true;
  };
}
