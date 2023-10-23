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
    ../../nix/home/deadd
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
    ../../nix/home/x11.nix
    ../../nix/home/yt-dlp.nix
    ../../nix/home/yubikey.nix
    ../../nix/modules/services
    ../../nix/modules/spellcheck.nix
    ../../nix/modules/desktop
    ../../nix/modules/desktop/browsers
    ../../nix/modules/desktop/browsers/firefox.nix
    ../../nix/modules/desktop/apps # TODO module
    ../../nix/modules/desktop/i3
  ];

  my.deadd.enable = true;
  modules.polybar.networks = [
    {
      interface = "wlp170s0";
      interface-type = "wireless";
    }
  ];
  modules.spellcheck.enable = true;
  modules.desktop.browsers = {
    default = "${
        lib.getExe config.programs.google-chrome.package
      } '--profile-directory=Profile 1'"; # work
    alternate = "${
        lib.getExe config.programs.google-chrome.package
      } '--profile-directory=Default'"; # personal
  };
  services.picom.enable = true;
  services.polybar.enable = true;
  services.polybar.settings = {};
  xsession.windowManager.i3.enable = true;
  xsession.windowManager.i3.config.terminal = "kitty";

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
