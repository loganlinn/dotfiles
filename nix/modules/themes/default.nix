{ inputs, options, config, lib, pkgs, ... }:

with lib;

let

  inherit (lib) mkOption types;
  inherit (inputs.home-manager.lib.hm.types) fontType;

  cfg = config.modules.theme;

in
{

  imports = [
    ./dracula
    ./arc
  ];

  options.modules.theme = with types; {

    active = mkOption {
      type = nullOr str;
      default = "arc";
      apply = v:
        let theme = builtins.getEnv "THEME"; in
        if theme != "" then theme else v;
      description = ''
        Name of the theme to enable. Can be overridden by the THEME environment
        variable. Themes can also be hot-swapped with 'hey theme $THEME'.
      '';
    };

    wallpaper = mkOption {
      type = nullOr path;
      default = null;
    };

    # loginWallpaper = mkOpt (either path null)
    #   (if cfg.wallpaper != null
    #   then toFilteredImage cfg.wallpaper "-gaussian-blur 0x2 -modulate 70 -level 5%"
    #   else null);

    fonts = {
      mono = mkOption {
        type = fontType;
        default = {
          name = "Monospace";
          size = 12;
        };
      };
      sans = mkOption {
        type = fontType;
        default = {
          name = "Sans";
          size = 12;
        };
      };
    };

    colors =
      let mkOpt = default: mkOption { type = type.str; inherit default; };
      in
      {
        black = mkOpt "#000000"; # 0
        red = mkOpt "#FF0000"; # 1
        green = mkOpt "#00FF00"; # 2
        yellow = mkOpt "#FFFF00"; # 3
        blue = mkOpt "#0000FF"; # 4
        magenta = mkOpt "#FF00FF"; # 5
        cyan = mkOpt "#00FFFF"; # 6
        silver = mkOpt "#BBBBBB"; # 7
        grey = mkOpt "#888888"; # 8
        brightred = mkOpt "#FF8800"; # 9
        brightgreen = mkOpt "#00FF80"; # 10
        brightyellow = mkOpt "#FF8800"; # 11
        brightblue = mkOpt "#0088FF"; # 12
        brightmagenta = mkOpt "#FF88FF"; # 13
        brightcyan = mkOpt "#88FFFF"; # 14
        white = mkOpt "#FFFFFF"; # 15

        # Color classes
        types = {
          bg = mkOpt cfg.colors.black;
          fg = mkOpt cfg.colors.white;
          panelbg = mkOpt cfg.colors.types.bg;
          panelfg = mkOpt cfg.colors.types.fg;
          border = mkOpt cfg.colors.types.bg;
          error = mkOpt cfg.colors.red;
          warning = mkOpt cfg.colors.yellow;
          highlight = mkOpt cfg.colors.white;
        };
      };
  };


  config = {

    home.packages = with pkgs; [
      paper-icon-theme # for rofi
      pywal
      wpgtk # gui for pywal ('wpg' command)
      siji # iconic bitmap font
    ];

    home.pointerCursor = {
      x11.enable = true;
      gtk.enable = true;
    };

    gtk = {
      enable = true;
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };

    # Workaround for apps that use libadwaita which does locate GTK settings via XDG.
    # https://www.reddit.com/r/swaywm/comments/qodk20/gtk4_theming_not_working_how_do_i_configure_it/hzrv6gr/?context=3
    home.sessionVariables.GTK_THEME = config.gtk.theme.name;

    qt.platformTheme = "gtk";

    services.dunst.iconTheme = config.gtk.iconTheme;

    services.xsettingsd = {
      enable = true;
      settings = with config; {
        # When running, most GNOME/GTK+ applications prefer those settings instead of *.ini files
        "Net/IconThemeName" = config.gtk.iconTheme.name;
        "Net/ThemeName" = config.gtk.theme.name;
        "Gtk/CursorThemeName" = config.xsession.pointerCursor.name;
      };
    };

    # config = mkIf (cfg.active != null) (mkMerge [
    #   # Read xresources files in ~/.config/xtheme/* to allow modular configuration
    #   # of Xresources.
    #   (
    #     let xrdb = ''cat "$XDG_CONFIG_HOME"/xtheme/* | ${pkgs.xorg.xrdb}/bin/xrdb -load'';
    #     in
    #     {
    #       home.configFile."xtheme.init" = {
    #         text = xrdb;
    #         executable = true;
    #       };
    #       modules.theme.onReload.xtheme = xrdb;
    #     }
    #   )

    #   (mkIf config.modules.desktop.bspwm.enable {
    #     home.configFile."bspwm/rc.d/05-init" = {
    #       text = "$XDG_CONFIG_HOME/xtheme.init";
    #       executable = true;
    #     };
    #   })

    #   {
    #     home.configFile = {
    #       "xtheme/00-init".text = with cfg.colors; ''
    #         #define bg   ${types.bg}
    #         #define fg   ${types.fg}
    #         #define blk  ${black}
    #         #define red  ${red}
    #         #define grn  ${green}
    #         #define ylw  ${yellow}
    #         #define blu  ${blue}
    #         #define mag  ${magenta}
    #         #define cyn  ${cyan}
    #         #define wht  ${white}
    #         #define bblk ${grey}
    #         #define bred ${brightred}
    #         #define bgrn ${brightgreen}
    #         #define bylw ${brightyellow}
    #         #define bblu ${brightblue}
    #         #define bmag ${brightmagenta}
    #         #define bcyn ${brightcyan}
    #         #define bwht ${silver}
    #       '';
    #       "xtheme/05-colors".text = ''
    #         *.foreground: fg
    #         *.background: bg
    #         *.color0:  blk
    #         *.color1:  red
    #         *.color2:  grn
    #         *.color3:  ylw
    #         *.color4:  blu
    #         *.color5:  mag
    #         *.color6:  cyn
    #         *.color7:  wht
    #         *.color8:  bblk
    #         *.color9:  bred
    #         *.color10: bgrn
    #         *.color11: bylw
    #         *.color12: bblu
    #         *.color13: bmag
    #         *.color14: bcyn
    #         *.color15: bwht
    #       '';
    #       "xtheme/05-fonts".text = with cfg.fonts.mono; ''
    #         *.font: xft:${name}:pixelsize=${toString(size)}
    #         Emacs.font: ${name}:pixelsize=${toString(size)}
    #       '';
    #       # GTK
    #       "gtk-3.0/settings.ini".text = ''
    #         [Settings]
    #         ${optionalString (cfg.gtk.theme != "")
    #           ''gtk-theme-name=${cfg.gtk.theme}''}
    #         ${optionalString (cfg.gtk.iconTheme != "")
    #           ''gtk-icon-theme-name=${cfg.gtk.iconTheme}''}
    #         ${optionalString (cfg.gtk.cursorTheme != "")
    #           ''gtk-cursor-theme-name=${cfg.gtk.cursorTheme}''}
    #         gtk-fallback-icon-theme=gnome
    #         gtk-application-prefer-dark-theme=true
    #         gtk-xft-hinting=1
    #         gtk-xft-hintstyle=hintfull
    #         gtk-xft-rgba=none
    #       '';
    #       # GTK2 global theme (widget and icon theme)
    #       "gtk-2.0/gtkrc".text = ''
    #         ${optionalString (cfg.gtk.theme != "")
    #           ''gtk-theme-name="${cfg.gtk.theme}"''}
    #         ${optionalString (cfg.gtk.iconTheme != "")
    #           ''gtk-icon-theme-name="${cfg.gtk.iconTheme}"''}
    #         gtk-font-name="Sans ${toString(cfg.fonts.sans.size)}"
    #       '';
    #       # QT4/5 global theme
    #       "Trolltech.conf".text = ''
    #         [Qt]
    #         ${optionalString (cfg.gtk.theme != "")
    #           ''style=${cfg.gtk.theme}''}
    #       '';
    #     };

    #     fonts.fontconfig.defaultFonts = {
    #       sansSerif = [ cfg.fonts.sans.name ];
    #       monospace = [ cfg.fonts.mono.name ];
    #     };
    #   }

    #   (mkIf (cfg.wallpaper != null)
    #     # Set the wallpaper ourselves so we don't need .background-image and/or
    #     # .fehbg polluting $HOME
    #     (
    #       let
    #         wCfg = config.services.xserver.desktopManager.wallpaper;
    #         command = ''
    #           if [ -e "$XDG_DATA_HOME/wallpaper" ]; then
    #             ${pkgs.feh}/bin/feh --bg-${wCfg.mode} \
    #               ${optionalString wCfg.combineScreens "--no-xinerama"} \
    #               --no-fehbg \
    #               $XDG_DATA_HOME/wallpaper
    #           fi
    #         '';
    #       in
    #       {
    #         services.xserver.displayManager.sessionCommands = command;
    #         modules.theme.onReload.wallpaper = command;

    #         home.dataFile = mkIf (cfg.wallpaper != null) {
    #           "wallpaper".source = cfg.wallpaper;
    #         };
    #       }
    #     ))

    #   (mkIf (cfg.loginWallpaper != null) {
    #     services.xserver.displayManager.lightdm.background = cfg.loginWallpaper;
    #   })

    #   (mkIf (cfg.onReload != { })
    #     (
    #       let reloadTheme =
    #         with pkgs; (writeScriptBin "reloadTheme" ''
    #           #!${stdenv.shell}
    #           echo "Reloading current theme: ${cfg.active}"
    #           ${concatStringsSep "\n"
    #             (mapAttrsToList (name: script: ''
    #               echo "[${name}]"
    #               ${script}
    #             '') cfg.onReload)}
    #         '');
    #       in
    #       {
    #         user.packages = [ reloadTheme ];
    #         system.userActivationScripts.reloadTheme = ''
    #           [ -z "$NORELOAD" ] && ${reloadTheme}/bin/reloadTheme
    #         '';
    #       }
    #     ))
    # ]);

  };
}
