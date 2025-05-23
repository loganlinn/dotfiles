{
  inputs,
  inputs',
  self,
  config,
  lib,
  pkgs,
  nix-colors,
  ...
}: {
  imports = [
    self.homeModules.common
    self.homeModules.nix-colors
    ../../nix/home/dev # TODO module
    ../../nix/home/emacs
    ../../nix/home/doom
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
    ../../nix/home/secrets.nix
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
    ../../nix/modules/desktop/i3
    # inputs.hyprland.homeManagerModules.default
    # {
    #   wayland.windowManager.hyprland = {
    #     enable = true;
    #     # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    #     # package = null;
    #     # portalPackage = null;
    #     package = inputs'.hyprland.packages.hyprland;
    #     portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
    #     plugins = [
    #       # inputs'.hyprland-plugins.packages.hyprbars
    #     ];
    #     settings = {
    #       "$mod" = "SUPER";
    #       bind =
    #         [
    #           "$mod, RETURN, exec, kitty"
    #           "$mod, F, exec, firefox"
    #           ", Print, exec, grimblast copy area"
    #         ]
    #         ++ [
    #           ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
    #           ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    #           ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    #           ", XF86AudioPlay, exec, playerctl play-pause"
    #           ", XF86AudioPrev, exec, playerctl previous"
    #           ", XF86AudioNext, exec, playerctl next"
    #         ]
    #         ++ (
    #           # workspaces
    #           # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
    #           builtins.concatLists (
    #             builtins.genList (
    #               i:
    #               let
    #                 ws = i + 1;
    #               in
    #               [
    #                 "$mod, code:1${toString i}, workspace, ${toString ws}"
    #                 "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
    #               ]
    #             ) 9
    #           )
    #         );
    #     };
    #   };
    #   services.playerctl.enable = true;
    #   home.pointerCursor = {
    #     gtk.enable = true;
    #     # package = pkgs.bibata-cursors;
    #     # name = "Bibata-Modern-Classic";
    #     # size = 16;
    #   };
    #   gtk = {
    #     enable = true;
    #     # theme = {
    #     #   package = pkgs.flat-remix-gtk;
    #     #   name = "Flat-Remix-GTK-Grey-Darkest";
    #     # };
    #     # iconTheme = {
    #     #   package = pkgs.adwaita-icon-theme;
    #     #   name = "Adwaita";
    #     # };
    #     # font = {
    #     #   name = "Sans";
    #     #   size = 11;
    #     # };
    #   };
    # }
  ];

  # my.python.package = pkgs.python311;
  my.deadd.enable = true;
  modules.polybar.monitor = "eDP-1";
  modules.polybar.networks = [
    {
      interface = "wlp170s0";
      interface-type = "wireless";
    }
  ];
  modules.spellcheck.enable = true;
  modules.desktop.browsers = {
    default = "${lib.getExe config.programs.google-chrome.package} '--profile-directory=Default'";
    alternate = "${lib.getExe config.programs.google-chrome.package} '--profile-directory=Profile 2'";
  };
  services.picom.enable = true;
  services.polybar.enable = true;
  services.polybar.settings = {};
  xsession.windowManager.i3.enable = true;
  xsession.windowManager.i3.config.terminal = "kitty";

  colorScheme = nix-colors.colorSchemes.doom-one; # nix-colors

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
  programs.nh.enable = false;
  # error: builder for '/nix/store/2f6m4847kdxkg36w408yfvc6yxqrf7w7-python3.11-stem-1.8.2.drv' failed with exit code 1;
  #    last 10 log lines:
  #    >   https://pypi.org/project/pycodestyle/
  #    >
  #    > TESTING FAILED (1 seconds)
  #    >   [UNIT TEST] test_descriptor_signing (test.unit.descriptor.server_descriptor.TestServerDescriptor) ... ERROR
  #    >   [UNIT TEST] test_descriptor_signing (test.unit.descriptor.extrainfo_descriptor.TestExtraInfoDescriptor) ... ERROR
  #    >
  #    > You can re-run just these tests with:
  #    >
  #    >   run_tests.py --unit --test descriptor.server_descriptor
  #    >   run_tests.py --unit --test descriptor.extrainfo_descriptor
  #    For full logs, run 'nix log /nix/store/2f6m4847kdxkg36w408yfvc6yxqrf7w7-python3.11-stem-1.8.2.drv'``
  programs.qutebrowser.enable = false; # disabled due to above error
  programs.ssh.enable = true;
  programs.nix-index.enable = false;
  programs.nix-index.enableZshIntegration = config.programs.nix-index.enable;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # advanced-scene-switcher
      # droidcam-obs
      input-overlay
      obs-backgroundremoval
      obs-command-source
      obs-freeze-filter
      obs-gstreamer
      # obs-replay-source
      obs-pipewire-audio-capture
      # obs-source-record
      obs-source-switcher
      # obs-vaapi
      # obs-vintage-filter
      # obs-vkcapture
      # obs-websocket
      # waveform
    ];
  };

  home.packages = with pkgs; [
    discord
  ];

  home.stateVersion = "22.11";
}
