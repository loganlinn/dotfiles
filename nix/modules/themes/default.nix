{ inputs, options, config, lib, pkgs, ... }:

let
  inherit (builtins)
    getEnv
    isNull
    pathExists
    ;

  inherit (lib)
    mkAliasDefinitions
    mkAliasOptionModule
    mkIf
    mkMerge
    mkOption
    mkOptionDefault
    optional
    types
    ;

  inherit (inputs.home-manager.lib.hm.types)
    fontType;

  inherit (inputs.nix-colors.lib-contrib)
    gtkThemeFromScheme
    shellThemeFromScheme
    nixWallpaperFromScheme;

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
      type = with types; nullOr str;
      default = "arc";
      apply = v:
        let theme = getEnv "THEME"; in
        if theme != "" then theme else v;
      description = ''
        Name of the theme to enable. Can be overridden by the THEME environment
        variable. Themes can also be hot-swapped with 'hey theme $THEME'.
      '';
    };

    wallpaper = mkOption {
      type = with types; nullOr (either string path);
      default = null;
      apply = v:
        let wallpaper = getEnv "WALLPAPER";
        in if wallpaper != "" then wallpaper else v;
    };

    fonts = {
      mono = mkOption {
        type = fontType;
        default = {
          package = config.modules.fonts.nerdfonts.package;
          name = "JetBrainsMono Nerd Font Mono";
          size = 11;
        };
      };
      serif = mkOption {
        type = fontType;
        default = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
          size = 10;
        };
      };
      sans = mkOption {
        type = fontType;
        default = {
          package = config.modules.fonts.nerdfonts.package;
          name = "Noto Sans";
          size = 10;
        };
      };
    };

    onReload = mkOption {
      type = with types; attrsOf lines;
      default = { };
    };

    # colors = with types; submodule {
    #   options = {
    #   };
    # };
  };

  config = mkIf (!isNull cfg.active) (mkMerge [
    # Color Scheme: doom-one
    # Adapted from https://github.com/doomemacs/themes/blob/master/themes/doom-one-theme.el
    {
      colorScheme = {
        name = "doom-one";
        author = "Henrik Lissner (https://github.com/doomemacs/themes/blob/master/themes/doom-one-theme.el)";
        slug = "doom-one";
        colors = rec {
          # https://github.com/chriskempson/base16/blob/main/styling.md
          base00 = bg-alt; # Default background
          base01 = bg; # Lighter Background (Used for status bars, line number and folding marks)
          base02 = muted-blue; # Selection Background
          base03 = comments; # Comments, Invisibles, Line Highlighting
          base04 = fg-alt; # Dark foreground (used for status bars)
          base05 = fg; # Default foregrund, caret, delimiters, operators
          base06 = base8; # Light foreground
          base07 = base7; # Light background
          base08 = red; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
          base09 = constants; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
          base0A = highlight; # Classes, Markup Bold, Search Text Background
          base0B = vc-added; # Strings, Inherited Class, Markup Code, Diff Inserted
          base0C = dark-cyan; # Support, Regular Expressions, Escape Characters, Markup Quotes
          base0D = functions; # Functions, Methods, Attribute IDs, Headings
          base0E = vc-modified; # Keywords, Storage, Selector, Markup Italic, Diff Changed
          base0F = warning; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>

          # named colors
          bg = "282c34";
          fg = "bbc2cf";
          bg-alt = "21242b";
          fg-alt = "5b6268";
          base0 = "1b2229";
          base1 = "1c1f24";
          base2 = "202328";
          base3 = "23272e";
          base4 = "3f444a";
          base5 = "5b6268";
          base6 = "73797e";
          base7 = "9ca0a4";
          base8 = "dfdfdf";
          grey = "3f444a";
          red = "ff6c6b";
          orange = "da8548";
          green = "98be65";
          teal = "4db5bd";
          yellow = "ecbe7b";
          blue = "51afef";
          dark-blue = "2257a0";
          magenta = "c678dd";
          violet = "a9a1e1";
          cyan = "46d9ff";
          dark-cyan = "5699af";
          muted-blue = "387aa7";
          highlight = blue;
          vertical-bar = base1;
          selection = dark-blue;
          builtin = magenta;
          comments = base5;
          doc-comments = base5;
          constants = violet;
          functions = magenta;
          keywords = blue;
          methods = cyan;
          operators = blue;
          type = yellow;
          strings = green;
          variables = magenta;
          numbers = orange;
          region = bg-alt;
          error = red;
          warning = yellow;
          success = green;
          vc-modified = orange;
          vc-added = green;
          vc-deleted = red;
        };
      };
    }
    {
      modules.fonts.enable = true;

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
        ${lib.pipe config.colorScheme.colors [
          (lib.filterAttrs (name: _: lib.hasPrefix "base" name))
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
      gtk.font = cfg.fonts.sans;

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

    (mkIf config.programs.fzf.enable {
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
    })

  ]);
}
