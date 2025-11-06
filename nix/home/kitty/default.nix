{
  inputs',
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; # FIXME

  let
    cfg = config.programs.kitty;
  in {
    programs.kitty = mkIf cfg.enable {
      enableGitIntegration = mkDefault true;
      font = config.my.fonts.terminal;
      shellIntegration.enableBashIntegration = true;
      shellIntegration.enableZshIntegration = true;
      shellIntegration.enableFishIntegration = true;
      settings = {
        # Appearance
        window_padding_width = 5;
        hide_window_decorations = "titlebar-only";
        dim_opacity = "0.3";
        inactive_text_alpha = "0.75";
        disable_ligatures = "cursor"; # disable ligatures when cursor is on them
        cursor_shape = "block";
        cursor_shape_unfocused = "hollow";
        cursor_underline_thickness = 1;
        active_border_color = "#bd93f9";
        inactive_border_color = "#414550";
        dynamic_background_opacity = "yes";
        kitten_alias = "hints hints --hints-offset=0 --alphabet=abcdefghijklmnopqrstuvwxyz";

        # Behavior
        shell_integration = "enabled";
        allow_remote_control = "yes"; # "socket-only";
        env = "read_from_shell=PATH LANG LC_* XDG_* EDITOR VISUAL";
        confirm_os_window_close = 0;
        notify_on_cmd_finish = "invisible 10";
        enabled_layouts = concatStringsSep "," [
          "tall:bias=66"
          "fat:bias=66"
          "grid"
          "horizontal"
          "splits"
          "stack"
          "vertical"
        ];
        window_resize_step_cells = 2;
        window_resize_step_lines = 2;

        # Links
        allow_hyperlinks = "yes";
        url_style = "curly";
        detect_urls = true;
        open_url_with = "default";
        url_prefixes = "http https file ftp gemini irc gopher mailto news git";

        # Tab bar
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_bar_min_tabs = "2";
        tab_switch_strategy = "previous";
        tab_powerline_style = "angled";
        # tab_title_template = "{title}";
        active_tab_font_style = "bold";
        inactive_tab_font_style = "normal";
        tab_activity_symbol = "";

        # [Scrollback](https://sw.kovidgoyal.net/kitty/conf/#scrollback)
        scrollback_lines = 2000;
        scrollback_pager_history_size = 1024; # MB
        # scrollback_pager = "${./scrollback_pager.sh} 'INPUT_LINE_NUMBER' 'CURSOR_LINE' 'CURSOR_COLUMN'";

        # MacOS
        macos_titlebar_color = "background";
        macos_option_as_alt = "yes";
      };

      extraConfig = ''
        include keyboard.conf
        include mouse.conf
        include theme.conf
        include kitty.local.conf
      '';
    };

    xdg.configFile = mkIf cfg.enable (
      (
        listToAttrs
        (map (
            name:
              nameValuePair "kitty/${name}" {
                source = config.lib.file.mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/kitty/${name}";
              }
          )
          [
            "keyboard.conf"
            "mouse.conf"
            "open-actions.conf"
            "theme.conf"
            "diff.conf"
            "choose-files.conf"
            "quick-access-terminal.conf"
            "grab.conf"
            "1.kitty-session"
            "2.kitty-session"
            "2.kitty-session"
          ])
      )
      // {
        "kitty/dracula".source = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "kitty";
          rev = "87717a3f00e3dff0fc10c93f5ff535ea4092de70";
          hash = "sha256-78PTH9wE6ktuxeIxrPp0ZgRI8ST+eZ3Ok2vW6BCIZkc=";
        };
        "kitty/smart_scroll.py" = {
          executable = true;
          source = "${
            pkgs.fetchFromGitHub {
              owner = "yurikhan";
              repo = "kitty-smart-scroll";
              rev = "8aaa91b9f52527c3dbe395a79a90aea4a879857a";
              hash = "sha256-QqNYi5s7VqOj0LBCaZKVHe65j75NBs3WYPdeGbYYXVo=";
            }
          }/smart_scroll.py";
        };
        "kitty/kitty_grab".source = pkgs.fetchFromGitHub {
          owner = "yurikhan";
          repo = "kitty_grab";
          rev = "969e363295b48f62fdcbf29987c77ac222109c41";
          hash = "sha256-DamZpYkyVjxRKNtW5LTLX1OU47xgd/ayiimDorVSamE=";
        };
      }
    );

    programs.rofi.terminal = mkDefault (getExe cfg.package);

    home.packages = let
      writeKittyBin = name: args:
        pkgs.writeShellScriptBin name ''exec kitty ${escapeShellArgs (map toString (toList args))} "$@"'';
    in
      mkIf cfg.enable (
        [
          inputs'.kitty-tab-switcher.packages.default
          (writeKittyBin "kitty-diff" [
            "+kitten"
            "diff"
          ])
          (writeKittyBin "kitty-ssh" [
            "+kitten"
            "ssh"
          ])
          (writeKittyBin "kitty-cat" [
            "+kitten"
            "icat"
          ])
          (writeKittyBin "kitty-panel" [
            "+kitten"
            "panel"
          ])
          (writeKittyBin "kitty-ask" [
            "+kitten"
            "ask"
          ])
        ]
        ++ optionals pkgs.stdenv.isLinux [
          (writeShellScriptBin "x-terminal-emulator" ''exec kitty "$@"'')
        ]
      );
  }
