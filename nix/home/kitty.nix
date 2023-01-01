{pkgs, ...}: {
  # Kitty terminal
  # https://sw.kovidgoyal.net/kitty/conf.html
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.kitty.enable
  programs.kitty = {
    enable = true;

    # darwinLaunchOptions = {};

    # font = "Victor Mono";

    # keybindings = {};

    settings = {
      font_size =
        if pkgs.stdenvNoCC.isDarwin
        then 14
        else 12;
      disable_ligatures = "cursor"; # disable ligatures when cursor is on them

      # Window layout
      hide_window_decorations = "titlebar-only";
      window_padding_width = "10";

      url_style = "curly";
      detect_urls = true;
      open_url_with = "default";
      url_prefixes = "http https file ftp gemini irc gopher mailto news git";

      copy_on_select = false;

      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_bar_min_tabs = "2";
      tab_switch_strategy = "previous";
      tab_separator = " ┇";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
      tab_activity_symbol = "";

      background_opacity = "1.0";
      dim_opacity = "0.75";

      macos_titlebar_color = "background";
      macos_option_as_alt = "yes";
    };

    # environment = {};

    extraConfig = ''
      # font_features PragmataProMonoLiga-Italic +ss06
      # font_features PragmataProMonoLiga-BoldItalic +ss07
      # modify_font underline_thickness 400%
      # modify_font underline_position 2

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
}
