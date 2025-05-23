{
  config,
  lib,
  pkgs,
  nix-colors,
  ...
}:
with lib; let
  inherit (nix-colors.lib.contrib {inherit pkgs;}) vimThemeFromScheme shellThemeFromScheme;

  cfg = config.modules.theme;
in {
  imports = [
    ./dracula
    ./arc
  ];

  options.modules.theme = with types; {
    active = mkOption {
      type = with types; nullOr str;
      default = "arc";
      apply = v: let
        theme = builtins.getEnv "THEME";
      in
        if theme != ""
        then theme
        else v;
      description = ''
        Name of the theme to enable. Can be overridden by the THEME environment
        variable. Themes can also be hot-swapped with 'hey theme $THEME'.
      '';
    };

    wallpaper = mkOption {
      type = with types; nullOr (either str path);
      default = null;
      apply = v: let
        wallpaper = builtins.getEnv "WALLPAPER";
      in
        if wallpaper != ""
        then wallpaper
        else v;
    };

    onReload = mkOption {
      type = with types; attrsOf lines;
      default = {};
    };

    vimTheme = mkOption {
      type = types.package;
      readOnly = true;
      default = vimThemeFromScheme {scheme = config.colorScheme;};
    };
  };

  config = mkIf (cfg.active != null) (mkMerge [
    {
      home.packages = with pkgs;
        [
          # zafiro-icons
          paper-icon-theme
          pywal
          wpgtk # gui for pywal ('wpg' command)
          siji # iconic bitmap font

          config.my.fonts.sans.package
          config.my.fonts.serif.package
          config.my.fonts.mono.package
          config.my.fonts.terminal.package
        ]
        ++ config.my.fonts.packages;

      xdg.dataFile."nix-colors.sh" = {
        text = (shellThemeFromScheme {scheme = config.colorScheme;}).text;
        executable = true;
      };

      home.pointerCursor = mkOptionDefault {
        package = pkgs.paper-gtk-theme;
        name = "Paper";
        x11.enable = true;
        gtk.enable = true;
      };

      # xresources.properties = {
      #   # Type of subpixel antialiasing (none, rgb, bgr, vrgb or vbgr)
      #   "Xft.rgba" = "rgb";
      #   "Xft.antialias" = "1";
      #   "Xft.hinting" = "1";
      #   "Xft.autohint" = "0";
      #   "Xft.hintstyle" = "hintslight";
      # };

      # similar to https://github.com/janoamaral/Xresources-themes
      xresources.extraConfig = ''
        ${pipe config.colorScheme.palette [
          (filterAttrs (name: _: hasPrefix "base0" name))
          (mapAttrsToList (name: value: "#define ${name} #${value}"))
          (concatStringsSep "\n")
        ]}

        *.foreground:   base05
        #ifdef background_opacity
        *.background:   [background_opacity]base00
        #else
        *.background:   base00
        #endif
        *.cursorColor:  base05

        ! black
        *.color0:       base00
        ! red
        *.color1:       base08
        *.color2:       base0B
        *.color3:       base0A
        *.color4:       base0D
        *.color5:       base0E
        *.color6:       base0C
        *.color7:       base05

        *.color8:       base03
        *.color9:       base09
        *.color10:      base01
        *.color11:      base02
        *.color12:      base04
        *.color13:      base06
        *.color14:      base0F
        *.color15:      base07
      '';

      # Workaround for apps that use libadwaita which does locate GTK settings via XDG.
      # https://www.reddit.com/r/swaywm/comments/qodk20/gtk4_theming_not_working_how_do_i_configure_it/hzrv6gr/?context=3
      home.sessionVariables.GTK_THEME = mkIf config.gtk.enable config.gtk.theme.name;

      services.xsettingsd = {
        enable = true;
        settings = with config; {
          # When running, most GNOME/GTK+ applications prefer those settings instead of *.ini files
          "Net/IconThemeName" = config.gtk.iconTheme.name;
          "Net/ThemeName" = config.gtk.theme.name;
          "Gtk/CursorThemeName" = config.xsession.pointerCursor.name;
        };
      };
    }

    (mkIf config.gtk.enable {
      gtk.font = config.my.fonts.sans;

      gtk.iconTheme = mkOptionDefault {
        package = pkgs.paper-gtk-theme;
        name = "Paper";
      };

      # https://docs.gtk.org/gtk4
      # gtk4.extraConfig = { };

      # https://docs.gtk.org/gtk3
      gtk.gtk3.extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb"; # The type of subpixel antialiasing to use. The possible values are none, rgb, bgr, vrgb, vbgr.
        gtk-decoration-layout = "menu:";
      };

      # https://docs.gtk.org/gtk2
      gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk.gtk2.extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    })

    (mkIf config.qt.enable {
      qt.useGtkTheme = true;
    })

    {
      # programs.rofi.font = cfg.fonts.mono.name;
      # programs.rofi.theme = let
      #   inherit (config.lib.formats.rasi) mkLiteral;
      #   c = lib.mapAttrs (_: v: mkLiteral "#${v}") config.colorScheme.palette;
      # in {
      #   "*" = {
      #     red = c.base08;
      #     lightbg = c.base01;
      #     lightfg = c.base06;
      #     blue = c.base0D;
      #     background = c.base00;
      #     foreground = c.base05;
      #     border-color = c.base03;
      #     spacing = 2;

      #     separatorcolor = "@foreground";
      #     selected-normal-foreground = "@lightbg";
      #     selected-normal-background = "@lightfg";
      #     selected-active-foreground = "@background";
      #     selected-active-background = "@blue";
      #     selected-urgent-foreground = "@background";
      #     selected-urgent-background = "@red";
      #     normal-foreground = "@foreground";
      #     normal-background = "@background";
      #     active-foreground = "@blue";
      #     active-background = "@background";
      #     urgent-foreground = "@red";
      #     urgent-background = "@background";
      #     alternate-normal-foreground = "@foreground";
      #     alternate-normal-background = "@lightbg";
      #     alternate-active-foreground = "@blue";
      #     alternate-active-background = "@lightbg";
      #     alternate-urgent-foreground = "@red";
      #     alternate-urgent-background = "@lightbg";
      #   };
      #   window = {
      #     background-color = "@background";
      #     border = "1";
      #     padding = "5";
      #   };
      #   mainbox = {
      #     border = "0";
      #     padding = "0";
      #   };
      #   message = {
      #     border = "1px dash 0px 0px ";
      #     border-color = "@separatorcolor";
      #     padding = "1px ";
      #   };
      #   textbox = {
      #     text-color = "@foreground";
      #   };
      #   listview = {
      #     fixed-height = "0";
      #     border = "2px dash 0px 0px ";
      #     border-color = "@separatorcolor";
      #     spacing = "2px ";
      #     scrollbar = "true";
      #     padding = "2px 0px 0px ";
      #   };
      #   "element-text, element-icon" = {
      #     background-color = "inherit";
      #     text-color = "inherit";
      #   };
      #   element = {
      #     border = "0";
      #     padding = "1px ";
      #   };
      #   "element normal.normal" = {
      #     background-color = "@normal-background";
      #     text-color = "@normal-foreground";
      #   };
      #   "element normal.urgent" = {
      #     background-color = "@urgent-background";
      #     text-color = "@urgent-foreground";
      #   };
      #   "element normal.active" = {
      #     background-color = "@active-background";
      #     text-color = "@active-foreground";
      #   };
      #   "element selected.normal" = {
      #     background-color = "@selected-normal-background";
      #     text-color = "@selected-normal-foreground";
      #   };
      #   "element selected.urgent" = {
      #     background-color = "@selected-urgent-background";
      #     text-color = "@selected-urgent-foreground";
      #   };
      #   "element selected.active" = {
      #     background-color = "@selected-active-background";
      #     text-color = "@selected-active-foreground";
      #   };
      #   "element alternate.normal" = {
      #     background-color = "@alternate-normal-background";
      #     text-color = "@alternate-normal-foreground";
      #   };
      #   "element alternate.urgent" = {
      #     background-color = "@alternate-urgent-background";
      #     text-color = "@alternate-urgent-foreground";
      #   };
      #   "element alternate.active" = {
      #     background-color = "@alternate-active-background";
      #     text-color = "@alternate-active-foreground";
      #   };
      #   scrollbar = {
      #     width = "4px";
      #     border = "0";
      #     handle-color = "@normal-foreground";
      #     handle-width = "8px ";
      #     padding = "0";
      #   };
      #   sidebar = {
      #     border = "2px dash 0px 0px ";
      #     border-color = "@separatorcolor";
      #   };
      #   button = {
      #     spacing = "0";
      #     text-color = "@normal-foreground";
      #   };
      #   "button selected" = {
      #     background-color = "@selected-normal-background";
      #     text-color = "@selected-normal-foreground";
      #   };
      #   inputbar = {
      #     spacing = "0px";
      #     text-color = "@normal-foreground";
      #     padding = "1px ";
      #     children = "[ prompt,textbox-prompt-colon,entry,case-indicator ]";
      #   };
      #   case-indicator = {
      #     spacing = "0";
      #     text-color = "@normal-foreground";
      #   };
      #   entry = {
      #     spacing = "0";
      #     text-color = "@normal-foreground";
      #   };
      #   prompt = {
      #     spacing = "0";
      #     text-color = "@normal-foreground";
      #   };
      #   textbox-prompt-colon = {
      #     expand = "false";
      #     str = ":";
      #     margin = "0px 0.3000em 0.0000em 0.0000em ";
      #     text-color = "inherit";
      #   };
      # };
    }
  ]);
}
