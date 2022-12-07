{pkgs, ...}: {
  programs = {
    kitty = {
      enable = false; # TODO: finish migrating from config file
      font = "Fira Code Retina";
      # keybindings = {};
      # settings = {};
      # environment = {};
      extraConfig = ''
        # Nord Theme
          background #1c1c1c
          foreground #ddeedd
          cursor #e2bbef
          selection_background #4d4d4d
          color0 #3d352a
          color8 #554444
          color1 #cd5c5c
          color9 #cc5533
          color2 #86af80
          color10 #88aa22
          color3 #e8ae5b
          color11 #ffa75d
          color4 #6495ed
          color12 #87ceeb
          color5 #deb887
          color13 #996600
          color6 #b0c4de
          color14 #b0c4de
          color7 #bbaa99
          color15 #ddccbb
          selection_foreground #1c1c1c
      '';
    };
  };
}
