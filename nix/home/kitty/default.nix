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
        # "--override=allow_remote_control=socket-only"
        # "--listen-on=unix:~/.local/share/kitty/socket"
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
        map f1 launch --type=overlay --stdin-source=@screen_scrollback --stdin-add-formatting bat +G -R
        map f2 launch --type=overlay gh pr checks

        map kitty_mod+v paste_from_clipboard
        map kitty_mod+, move_tab_backward
        map kitty_mod+. move_tab_forward
        map kitty_mod+1 pass_selection_to_program
        map kitty_mod+; next_layout
        map kitty_mod+[ previous_tab
        map kitty_mod+] next_tab
        map kitty_mod+a>1 set_background_opacity 1
        map kitty_mod+a>d set_background_opacity default
        map kitty_mod+a>l set_background_opacity -0.1
        map kitty_mod+a>m set_background_opacity +0.1
        map kitty_mod+c copy_to_clipboard
        map kitty_mod+delete clear_terminal reset active
        map kitty_mod+e open_url_with_hints
        map kitty_mod+enter new_window_with_cwd
        map kitty_mod+escape kitty_shell window
        map kitty_mod+h neighboring_window left
        map kitty_mod+j neighboring_window down
        map kitty_mod+k neighboring_window up
        map kitty_mod+l neighboring_window right
        map kitty_mod+o goto_tab -1
        map kitty_mod+p>f kitten hints --type path --program -
        map kitty_mod+p>h kitten hints --type hash --program -
        map kitty_mod+p>l kitten hints --type line --program -
        map kitty_mod+p>n kitten hints --type linenum
        map kitty_mod+p>shift+f kitten hints --type path
        map kitty_mod+p>w kitten hints --type word --program -
        map kitty_mod+p>y kitten hints --type hyperlink
        map kitty_mod+q close_tab
        map kitty_mod+space>h move_window left
        map kitty_mod+space>j move_window down
        map kitty_mod+space>k move_window up
        map kitty_mod+space>l move_window right
        map kitty_mod+t new_tab_with_cwd
        map kitty_mod+u kitten unicode_input
        map kitty_mod+y>f kitten hints --type path --program @
        map kitty_mod+y>h kitten hints --type hash --program @
        map kitty_mod+y>l kitten hints --type line --program @
        map kitty_mod+y>w kitten hints --type word --program @

        map kitty_mod+left  resize_window narrower
        map kitty_mod+down  resize_window shorter
        map kitty_mod+up    resize_window taller
        map kitty_mod+right resize_window wider

        map kitty_mod+backspace change_font_size all 0
        map kitty_mod+equal     change_font_size all +2.0
        map kitty_mod+minus     change_font_size all -2.0

        map super+. set_tab_title
        map super+1 goto_tab 1
        map super+2 goto_tab 2
        map super+3 goto_tab 3
        map super+4 goto_tab 4
        map super+5 goto_tab 5
        map super+6 goto_tab 6
        map super+7 goto_tab 7
        map super+8 goto_tab 8
        map super+9 goto_tab 9
        map super+down scroll_to_prompt 1
        map super+n new_os_window_with_cwd
        map super+shift+w close_os_window
        map super+up scroll_to_prompt -1 2
        map super+w close_window
        map super+shift+t kitten themes
        map super+shift+r load_config_file
        map super+shift+d debug_config
        map super+shift+l dump_lines_with_attrs
        map super+shift+e show_kitty_env_vars

        clear_all_mouse_actions no

        mouse_map ctrl+alt+left       press       ungrabbed         mouse_selection   rectangle
        mouse_map ctrl+alt+left       triplepress ungrabbed         mouse_selection   line_from_point
        mouse_map ctrl+shift+left     press       grabbed           discard_event
        mouse_map ctrl+shift+left     release     grabbed,ungrabbed mouse_click_url
        mouse_map left                            click             ungrabbed         mouse_click_url_or_select
        mouse_map left                            doublepress       ungrabbed         mouse_selection word
        mouse_map left                            press             ungrabbed         mouse_selection normal
        mouse_map left                            triplepress       ungrabbed         mouse_selection line
        mouse_map middle                          release           ungrabbed         paste_from_selection
        mouse_map right               press       ungrabbed         mouse_select_command_output
        mouse_map shift+ctrl+alt+left press       ungrabbed,grabbed mouse_selection   rectangle
        mouse_map shift+ctrl+alt+left triplepress ungrabbed,grabbed mouse_selection   line_from_point
        mouse_map shift+left                      doublepress       ungrabbed,grabbed mouse_selection word
        mouse_map shift+left                      press             ungrabbed,grabbed mouse_selection normal
        mouse_map shift+left                      triplepress       ungrabbed,grabbed mouse_selection line
        mouse_map shift+left                      click             grabbed,ungrabbed mouse_click_url_or_select
        mouse_map shift+middle                    release           ungrabbed,grabbed paste_selection
        mouse_map shift+right         press       ungrabbed,grabbed mouse_selection   extend

        # Open any file with a fragment in vim, fragments are generated
        # by the hyperlink_grep kitten and nothing else so far.
        protocol file
        fragment_matches [0-9]+
        action launch --type=overlay vim +''${FRAGMENT} ''${FILE_PATH}

        # Open text files without fragments in the editor
        protocol file
        mime text/*
        action launch --type=overlay ''${EDITOR} ''${FILE_PATH}

        # BEGIN_KITTY_THEME
        # dracula
        include current-theme.conf
        # END_KITTY_THEME
      '';
    };

    xdg.configFile = {
      "kitty/diff.conf".source = "${dracula}/diff.conf";
      "kitty/current-theme.conf".source = "${dracula}/dracula.conf";
    };

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
