{ inputs, options, config, lib, pkgs, ... }:

with lib;

let
  inherit (inputs.home-manager.lib.hm.types) fontType;

  inherit (lib)
    mkAliasDefinitions
    mkAliasOptionModule;

  cfg = config.modules.theme;

  colorCfg = config.colorScheme.colors;
in
{
  imports = [
    ./dracula
    ./arc
  ];

  # Convenience for nix-colors
  options.colorScheme.colorsHex = mkOption {
    type = with types; attrsOf str;
    readOnly = true;
    default = (mapAttrs (name: value: "#${value}") colorCfg);
  };

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
          name = "Fira Code";
          size = 12;
        };
      };
      sans = mkOption {
        type = fontType;
        default = {
          name = "Fira Sans";
          size = 12;
        };
      };
    };

    colors =
      let
        mkColorSchemeAlias = name: mkOption {
          type = types.str;
          default = "#${config.colorScheme.colors.${name}}";
          readOnly = true;
        };
      in
      {
        # black = mkColorSchemeAlias "base00";
        # red = mkColorSchemeAlias "base01";
        # green = mkColorSchemeAlias "base02";
        # yellow = mkColorSchemeAlias "base03";
        # blue = mkColorSchemeAlias "base04";
        # magenta = mkColorSchemeAlias "base05";
        # cyan = mkColorSchemeAlias "base06";
        # silver = mkColorSchemeAlias "base07";
        # grey = mkColorSchemeAlias "base08";
        # brightred = mkColorSchemeAlias "base09";
        # brightgreen = mkColorSchemeAlias "base0A";
        # brightyellow = mkColorSchemeAlias "base0B";
        # brightblue = mkColorSchemeAlias "base0C";
        # brightmagenta = mkColorSchemeAlias "base0D";
        # brightcyan = mkColorSchemeAlias "base0E";
        # white = mkColorSchemeAlias "base0F";

        # https://github.com/chriskempson/base16/blob/main/styling.md
        # base00 - Default Background
        # base01 - Lighter Background (Used for status bars, line number and folding marks)
        # base02 - Selection Background
        # base03 - Comments, Invisibles, Line Highlighting
        # base04 - Dark Foreground (Used for status bars)
        # base05 - Default Foreground, Caret, Delimiters, Operators
        # base06 - Light Foreground (Not often used)
        # base07 - Light Background (Not often used)
        # base08 - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
        # base09 - Integers, Boolean, Constants, XML Attributes, Markup Link Url
        # base0A - Classes, Markup Bold, Search Text Background
        # base0B - Strings, Inherited Class, Markup Code, Diff Inserted
        # base0C - Support, Regular Expressions, Escape Characters, Markup Quotes
        # base0D - Functions, Methods, Attribute IDs, Headings
        # base0E - Keywords, Storage, Selector, Markup Italic, Diff Changed
        # base0F - Deprecated, Opening/Closing Embedded Language Tags, e.g.

        # Color classes
        types = let mkColorOpt = color: mkOption { type = types.str; default = colorCfg.${color}; }; in
          {
            bg = mkColorOpt "base00";
            panelbg = mkColorOpt "base01";
            selectionbg = mkColorOpt "base02";
            comment = mkColorOpt "base03";
            invisible = mkColorOpt "base03";
            fgdark = mkColorOpt "base04";
            panelfg = mkColorOpt "base04";
            fg = mkColorOpt "base05";
            caret = mkColorOpt "base05";
            operator = mkColorOpt "base05";
            delimiter = mkColorOpt "base05";
            fglight = mkColorOpt "base06";
            bglight = mkColorOpt "base07";
            variable = mkColorOpt "base07";
            xmltag = mkColorOpt "base08";
            markuplinktxt = mkColorOpt "base08";
            markuplists = mkColorOpt "base08";
            diffdeleted = mkColorOpt "base08";
            integer = mkColorOpt "base09";
            boolean = mkColorOpt "base09";
            const = mkColorOpt "base09";
            xmlattr = mkColorOpt "base09";
            linkurl = mkColorOpt "base09";
            classes = mkColorOpt "base0A";
            markupbold = mkColorOpt "base0A";
            searchtextbg = mkColorOpt "base0A";
            diffadded = mkColorOpt "base0B";
            markupcode = mkColorOpt "base0B";
            support = mkColorOpt "base0C";
            regex = mkColorOpt "base0C";
            escapechar = mkColorOpt "base0C";
            markupquote = mkColorOpt "base0C";
            function = mkColorOpt "base0D";
            method = mkColorOpt "base0D";
            attrname = mkColorOpt "base0D";
            heading = mkColorOpt "base0D";
            keyword = mkColorOpt "base0E";
            storage = mkColorOpt "base0E";
            selector = mkColorOpt "base0E";
            markupitalic = mkColorOpt "base0E";
            diffchanged = mkColorOpt "base0E";
            deprecated = mkColorOpt "base0F";
            openclose = mkColorOpt "base0F";


            border = mkColorOpt "base02";
            error = mkColorOpt "base08";
            warning = mkColorOpt "base0E";
            highlight = mkColorOpt "base03";
          };
      };
  };

  config = {
    home.packages = with pkgs; [
      paper-icon-theme # for rofi
      pywal
      wpgtk # gui for pywal ('wpg' command)
      siji # iconic bitmap font
      # base16-universal-manager
    ];

    home.pointerCursor = mkOptionDefault {
      package = pkgs.paper-gtk-theme;
      name = "Paper";
      x11.enable = true;
      gtk.enable = true;
    };

    gtk.enable = true;
    gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk.iconTheme = mkOptionDefault {
      package = pkgs.paper-gtk-theme;
      name = "Paper";
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
