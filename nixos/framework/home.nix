{ inputs, self, config, lib, pkgs, nix-colors, ... }:

{
  imports = [
    self.homeModules.common
    self.homeModules.nix-colors
    self.homeModules.secrets
    ../../nix/home/dev # TODO module
    ../../nix/home/emacs
    ../../nix/home/home-manager.nix
    # ../../nix/home/intellij.nix
    ../../nix/home/kitty
    # ../../nix/home/mpd.nix
    # ../../nix/home/mpv.nix
    # ../../nix/home/nnn.nix
    # ../../nix/home/polkit.nix
    ../../nix/home/pretty.nix
    # ../../nix/home/qalculate
    ../../nix/home/ssh.nix
    # ../../nix/home/sync.nix
    # ../../nix/home/urxvt.nix
    # ../../nix/home/vpn.nix
    # ../../nix/home/vscode.nix
    # ../../nix/home/yt-dlp.nix
    # ../../nix/home/yubikey.nix
    # ../../nix/modules/services
    # ../../nix/modules/spellcheck.nix
  ];

  colorScheme = nix-colors.colorSchemes.doom-one; # nix-colors
  gtk.enable = true;

  # dconf.settings = with lib.hm.gvariant; {
  #   "/org/gnome/desktop/input-sources" = {
  #     # current = "uint32 0";
  #     sources = [ (mkTuple [ "xkb" "us" ]) ];
  #     xkb-options = [ "ctrl:nocaps" "terminate:ctrl_alt_bksp" ];
  #   };
  # };

  programs.kitty.enable = true;
  programs.emacs.enable = true;
  programs.rofi.enable = true;
  programs.google-chrome.enable = true;
  programs.firefox.enable = true;
  programs.librewolf.enable = true;
  programs.qutebrowser.enable = true;
  programs.ssh.enable = true;
  programs.nix-index.enable = false;
  programs.nix-index.enableZshIntegration = config.programs.nix-index.enable;


  home.stateVersion = "22.11";
}
