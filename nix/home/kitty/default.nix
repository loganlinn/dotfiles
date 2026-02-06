{
  inputs',
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.programs.kitty;
  json = pkgs.formats.json {};
in {
  programs = mkIf cfg.enable {
    kitty = {
      enableGitIntegration = true;
      font = config.my.fonts.terminal;
      shellIntegration.enableBashIntegration = true;
      shellIntegration.enableZshIntegration = true;
      shellIntegration.enableFishIntegration = true;
      extraConfig = ''
        include kitty.common.conf
        include kitty.''${KITTY_OS}.conf
        include kitty.local.conf
      '';
    };

    rofi.terminal = mkDefault (getExe cfg.package);

    zsh = {
      initExtra = ''
        kitty-user-vars() {
          (($#)) || set -- --self
          kitty @ ls "$@" | jq '.[].tabs[].windows[0].user_vars'
        }

        kitty-window-id() {
          (($#)) || set -- --self
          kitty @ ls "$@" | jq '.[].tabs[].windows[].id'
        }
      '';
    };
  };

  xdg.configFile = mkIf cfg.enable (
    (listToAttrs (
      map
      (
        name:
          nameValuePair "kitty/${name}" {
            source = config.lib.file.mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/kitty/${name}";
          }
      )
      [
        "a.kitty-session"
        "b.kitty-session"
        "c.kitty-session"
        "choose-files.conf"
        "current-theme.conf"
        "diff.conf"
        "grab.conf"
        "kitty.common.conf"
        "kitty.linux.conf"
        "kitty.macos.conf"
        "launch-actions.conf"
        "open-actions.conf"
        "quick-access-terminal.conf"
        "tab_bar.py"
      ]
    ))
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
      "kitty/pyrightconfig.json".source = json.generate "pyrightconfig.json" {
        extraPaths = ["../../src/github.com/kovidgoyal/kitty"]; # src-get kovidgoyal/kitty
      };
    }
  );

  home = mkIf cfg.enable {
    packages = with pkgs;
      concatLists [
        [
          (writeShellScriptBin "kdiff" ''kitten diff "$@"'')
          (writeShellScriptBin "kssh" ''kitten ssh "$@"'')
          (writeShellScriptBin "icat" ''kitten icat "$@"'')
          # (writeShellScriptBin "kclaude" ''
          #   # TODO change cwd from currently active/focused kitty window via 'kitty @ ls'
          #   exec kitten quick-access-terminal \
          #     --instance-group=claude \
          #     -o app_id=kitty-quick-access-claude \
          #     -o edge=right \
          #     -o columns=140 \
          #     -o background_opacity=0.97 \
          #     -o hide_on_focus_lost=yes \
          #     -o confirm_os_window_close=yes \
          #     -o allow_remote_control=socket-only \
          #     -o listen_on="''${XDG_DATA_DIR:-$HOME/.local/share}/kitty/quick-access-claude.sock" \
          #     ''${KCLAUDE_DEFAULT_ARGS-} \
          #     claude
          # '')
        ]
        (optional pkgs.stdenv.isLinux (writeShellScriptBin "x-terminal-emulator" ''exec kitty "$@"''))
      ];

    shellAliases = {
      rg = "rg --hyperlink-format=kitty";
    };

    activation = {
      kittyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
          mkdir -p "${config.xdg.configHome}/kitty"
        touch "${config.xdg.configHome}/kitty/kitty.local.conf"
        chmod 600 "${config.xdg.configHome}/kitty/kitty.local.conf"
      '';
    };
  };
}
