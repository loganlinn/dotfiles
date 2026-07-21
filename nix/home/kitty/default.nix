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
  kittyThemes = pkgs.fetchFromGitHub {
    owner = "kovidgoyal";
    repo = "kitty-themes";
    rev = "e144651f75891cf4795ef1e7c24bb3e27c47aa06";
    hash = "sha256-cl79/m3tGZzGXBuwcIIBxsewrcgaFK0R0VRlRiiw5yk=";
  };
  kittyThemeFiles = [
    "Catppuccin-Macchiato.conf"
    "gruvbox-dark-soft.conf"
    "gruvbox-light-soft.conf"
    "tokyo_night_day.conf"
    "DarkOneNuanced.conf"
    "Doom_Vibrant.conf"
    "Dracula.conf"
    "kanagawabones.conf"
    "Nord.conf"
    "yorumi-shade.conf"
  ];
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

    zsh.initContent = builtins.readFile ./kitty.zshrc;
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
          "big_mode.py"
          "choose-files.conf"
          "claude-fork.py"
          "color_selector.py"
          "copy_cmd_with_output.py"
          "cssh.py"
          "current-theme.conf"
          "diff.conf"
          "file-menu.sh"
          "focus-drill.py"
          "grab.conf"
          "kitty.common.conf"
          "kitty.linux.conf"
          "kitty.macos.conf"
          "launch-actions.conf"
          "nerdfont_glyphnames.json"
          "nerdfont_selector.py"
          "open-actions.conf"
          "paste-actions.py"
          "quick-access-terminal.conf"
          "reopen_closed_tab.py"
          "sessions"
          "snap_splits.py"
          "ssh.conf"
          "stack_toggle.py"
          "tab_bar.py"
          "tab_flags.py"
          "user-var-hints.py"
          "watcher.py"
        ]
    ))
    // (listToAttrs (
      map
        (
          name:
          nameValuePair "kitty/themes/${name}" {
            source = "${kittyThemes}/themes/${name}";
          }
        )
        kittyThemeFiles
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
      "kitty/kitten_search".source = pkgs.fetchFromGitHub {
        owner = "trygveaa";
        repo = "kitty-kitten-search";
        rev = "992c1f3d220dc3e1ae18a24b15fcaf47f4e61ff8";
        hash = "sha256-Xy4dH2fzEQmKfqhmotVDEszuTqoISONGNfC1yfcdevs=";
      };
      "kitty/kitty_grab".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/src/github.com/loganlinn/kitty_grab";
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
      ]
      (optional pkgs.stdenv.isLinux (writeShellScriptBin "x-terminal-emulator" ''exec kitty "$@"''))
    ];

    sessionVariables = {
      KITTY_CACHE_DIRECTORY = "${config.xdg.cacheHome}/kitty"; # ie don't use ~/Library/Caches on darwin
    };

    shellAliases = {
      kf = "kitten choose-files";
      kls = "kitten @ ls";
      rg = "rg --hyperlink-format=kitty";
    };

    activation = {
      kittyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run mkdir $VERBOSE_ARG -p "${config.xdg.configHome}/kitty"
      '';
    };
  };

  my.src-get.repos."loganlinn/kitty_grab" = {};
}
