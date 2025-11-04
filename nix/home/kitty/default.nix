{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; # FIXME

  let
    dracula = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "kitty";
      rev = "87717a3f00e3dff0fc10c93f5ff535ea4092de70";
      hash = "sha256-78PTH9wE6ktuxeIxrPp0ZgRI8ST+eZ3Ok2vW6BCIZkc=";
    };
  in {
    programs.kitty = {
      enable = lib.mkDefault pkgs.stdenv.isLinux; # install via homebrew on darwin
      enableGitIntegration = mkDefault true;

      # Wrap package to fix apparent issue with how libxkbcommon is (not) loaded:
      # 'Failed to load libxkbcommon.xkb_keysym_from_name with error: Failed to find libxkbcommon'
      # package = (
      #   pkgs.kitty.overrideAttrs (
      #     {
      #       buildInputs ? [ ],
      #       postInstall ? "",
      #       ...
      #     }:
      #     {
      #       buildInputs = buildInputs ++ [ pkgs.makeWrapper ];
      #       postInstall =
      #         postInstall
      #         + ''
      #           wrapProgram $out/bin/kitty \
      #               --set LD_PRELOAD "${pkgs.libxkbcommon}/lib/libxkbcommon.so"
      #         '';
      #     }
      #   )
      # );

      darwinLaunchOptions = [
        "--override=allow_remote_control=socket-only"
        "--listen-on=unix:~/.local/share/kitty/socket"
        # "${getExe config.programs.zsh.package} --login"
      ];

      font = config.my.fonts.terminal;
      shellIntegration.enableBashIntegration = true;
      shellIntegration.enableZshIntegration = true;
      shellIntegration.enableFishIntegration = true;
      # keybindings = {
      #   "ctrl+alt+1" = "goto_tab 1";
      #   "ctrl+alt+2" = "goto_tab 2";
      #   "ctrl+alt+3" = "goto_tab 3";
      #   "ctrl+alt+4" = "goto_tab 4";
      #   "ctrl+alt+5" = "goto_tab 5";
      #   "ctrl+alt+6" = "goto_tab 6";
      #   "ctrl+alt+7" = "goto_tab 7";
      #   "ctrl+alt+8" = "goto_tab 8";
      #   "ctrl+alt+9" = "goto_tab 9";
      #   "ctrl+alt+enter" = "launch --cwd=current";
      #   "f1" = "show_scrollback";
      #   "kitty_mod+[" = "previous_tab";
      #   "kitty_mod+]" = "next_tab";
      #   "kitty_mod+;" = "next_layout";
      #   "kitty_mod+down" = "neighboring_window down";
      #   "kitty_mod+enter" = "new_window_with_cwd";
      #   "kitty_mod+f3" = "kitten themes";
      #   "kitty_mod+h" = "neighboring_window left";
      #   "kitty_mod+j" = "neighboring_window down";
      #   "kitty_mod+k" = "neighboring_window up";
      #   "kitty_mod+l" = "neighboring_window right";
      #   "kitty_mod+left" = "neighboring_window left";
      #   "kitty_mod+n" = "new_os_window_with_cwd";
      #   "kitty_mod+right" = "neighboring_window right";
      #   "kitty_mod+t" = "new_tab_with_cwd";
      #   "kitty_mod+up" = "neighboring_window up";
      #   "kitty_mod+y>f" = "kitten hints --type path --program @";
      #   "kitty_mod+y>h" = "kitten hints --type hash --program @";
      #   "kitty_mod+y>l" = "kitten hints --type line --program @";
      #   "kitty_mod+y>w" = "kitten hints --type word --program @";
      #   "shift+super+w" = "close_os_window";
      #   "kitty_mod+o>t" = ''launch --type=overlay --cwd=current ${pkgs.yazi}/bin/yazi'';
      #   "kitty_mod+o>p" = ''launch --type=os-window --cwd=current bash -c 'gh pr checks --watch && read -n 1 -s -r -p "Press any key to exit"' '';
      #   "kitty_mod+/" = ''launch --type=overlay bash -i -c 'rg "^\s*(map|mouse_map)\s+.*" ~/.config/kitty/kitty.conf | fzf' '';
      #   # git stash show
      #   "kitty_mod+o>s" = ''kitten hints --type regex --regex '(?m)(stash@\{[^}]+\})' --program 'launch --type=overlay git stash show -p' '';
      #   "super+h" = "launch --location=vsplit --next-to=neighbor:left";
      #   "super+j" = "launch --location=hsplit --next-to=neighbor:down";
      #   "super+k" = "launch --location=hsplit --next-to=neighbor:up";
      #   "super+l" = "launch --location=vsplit --next-to=neighbor:right";
      #   "super+w" = "close_window";
      # };
      settings = {
        # Appearance
        window_padding_width = 5;
        hide_window_decorations = "titlebar-only";
        dim_opacity = "0.75";
        inactive_text_alpha = "0.75";
        disable_ligatures = "cursor"; # disable ligatures when cursor is on them
        cursor_shape = "Underline";
        cursor_underline_thickness = 1;

        # Behavior
        shell_integration = "enabled";
        allow_remote_control = "yes"; # "socket-only";
        confirm_os_window_close = 0;

        # Links
        url_style = "curly";
        detect_urls = true;
        open_url_with = "default";
        url_prefixes = "http https file ftp gemini irc gopher mailto news git";

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

        # [Scrollback](https://sw.kovidgoyal.net/kitty/conf/#scrollback)
        scrollback_lines = 2000;
        scrollback_pager_history_size = 1024; # MB
        scrollback_pager = "${./scrollback_pager.sh} 'INPUT_LINE_NUMBER' 'CURSOR_LINE' 'CURSOR_COLUMN'";

        # MacOS
        macos_titlebar_color = "background";
        macos_option_as_alt = "yes";
      };
      extraConfig = ''
        globinclude kitty.d/**/*.conf

        # BEGIN_KITTY_THEME
        # dracula
        include current-theme.conf
        # END_KITTY_THEME
      '';
    };

    xdg.configFile =
      attrsets.unionOfDisjoint {
        "kitty/diff.conf".source = "${dracula}/diff.conf";
        "kitty/current-theme.conf".source = "${dracula}/dracula.conf";
      } (
        let
          sourceDir = ../../../config/kitty/kitty.d;
          entries = builtins.readDir sourceDir;
        in
          lib.mapAttrs' (name: type:
            nameValuePair "kitty/kitty.d/${name}" {
              source = config.lib.file.mkOutOfStoreSymlink "${sourceDir}/${name}";
            })
          entries
      );

    programs.rofi.terminal = mkDefault (getExe config.programs.kitty.package);

    home.packages = let
      writeKittyBin = name: args:
        pkgs.writeShellScriptBin name ''exec kitty ${escapeShellArgs (map toString (toList args))} "$@"'';
    in
      with pkgs;
        [
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
        ];
  }
