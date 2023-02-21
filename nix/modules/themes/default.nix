{ inputs, options, config, lib, pkgs, ... }:

with lib;

let
  inherit (inputs.home-manager.lib.hm.types)
    fontType;

  inherit (inputs.nix-colors.lib-contrib)
    gtkThemeFromScheme
    shellThemeFromScheme
    nixWallpaperFromScheme;

  inherit (lib)
    mkAliasDefinitions
    mkAliasOptionModule;

  cfg = config.modules.theme;

  colorCfg = config.colorScheme.colors;

in
{
  imports = [
    ../fonts.nix
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

    fonts = {
      mono = mkOption {
        type = fontType;
        default = {
          package = config.modules.fonts.nerdfonts.package;
          name = "FiraCode Nerd Font Mono";
          size = 11;
        };
      };
      serif = mkOption {
        type = fontType;
        default = {
          package = config.modules.fonts.nerdfonts.package;
          name = "NotoSerif Nerd Font";
          size = 11;
        };
      };
      sans = mkOption {
        type = fontType;
        default = {
          package = config.modules.fonts.nerdfonts.package;
          name = "NotoSans Nerd Font";
          size = 11;
        };
      };
    };
  };

  config = {
    home.packages = with pkgs; [
      paper-icon-theme
      pywal
      wpgtk # gui for pywal ('wpg' command)
      siji # iconic bitmap font
    ]
    ++ optional (!isNull cfg.fonts.mono.package) cfg.fonts.mono.package
    ++ optional (!isNull cfg.fonts.sans.package) cfg.fonts.sans.package;

    home.pointerCursor = mkOptionDefault {
      package = pkgs.paper-gtk-theme;
      name = "Paper";
      x11.enable = true;
      gtk.enable = true;
    };

    gtk = mkIf config.gtk.enable {
      font = cfg.fonts.sans;

      iconTheme = mkOptionDefault {
        package = pkgs.paper-gtk-theme;
        name = "Paper";
      };

      # https://docs.gtk.org/gtk4
      # gtk4.extraConfig = { };

      # https://docs.gtk.org/gtk3
      gtk3.extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb"; # The type of subpixel antialiasing to use. The possible values are none, rgb, bgr, vrgb, vbgr.
        gtk-decoration-layout = "menu:";
      };

      # https://docs.gtk.org/gtk2
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk2.extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    };

    xresources.properties = {
      # Type of subpixel antialiasing (none, rgb, bgr, vrgb or vbgr)
      "Xft.rgba" = "rgb";
      "Xft.antialias" = "1";
      "Xft.hinting" = "1";
      "Xft.autohint" = "0";
      "Xft.hintstyle" = "hintslight";
    };

    # similar to https://github.com/janoamaral/Xresources-themes
    xresources.extraConfig = ''
      ${lib.pipe config.colorScheme.colors [
        (lib.mapAttrsToList (name: value: "#define ${name} #${value}"))
        (lib.concatStringsSep "\n")
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

    programs.fzf.defaultOptions = with config.colorScheme.colors; [
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--color 'fg:#${base05}'" # Text
      "--color 'bg:#${base00}'" # Background
      "--color 'preview-fg:#${base05}'" # Preview window text
      "--color 'preview-bg:#${base00}'" # Preview window background
      "--color 'hl:#${base0A}'" # Highlighted substrings
      "--color 'fg+:#${base0D}'" # Text (current line)
      "--color 'bg+:#${base02}'" # Background (current line)
      "--color 'gutter:#${base02}'" # Gutter on the left (defaults to bg+)
      "--color 'hl+:#${base0E}'" # Highlighted substrings (current line)
      "--color 'info:#${base0E}'" # Info line (match counters)
      "--color 'border:#${base0D}'" # Border around the window (--border and --preview)
      "--color 'prompt:#${base05}'" # Prompt
      "--color 'pointer:#${base0E}'" # Pointer to the current line
      "--color 'marker:#${base0E}'" # Multi-select marker
      "--color 'spinner:#${base0E}'" # Streaming input indicator
      "--color 'header:#${base05}'" # Header
    ];
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
