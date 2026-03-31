{
  inputs',
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my;
let
  cfg = config.programs.kitty;
  json = pkgs.formats.json { };
in
{
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

    zsh.initContent = ''
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
          "choose-files.conf"
          "current-theme.conf"
          "diff.conf"
          "grab.conf"
          "kitty.common.conf"
          "kitty.linux.conf"
          "kitty.macos.conf"
          "launch-actions.conf"
          "open-actions.conf"
          "paste-actions.py"
          "quick-access-terminal.conf"
          "sessions"
          "ssh.conf"
          "tab_bar.py"
          "themes"
          "user-var-hints.py"
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
      "kitty/kitten_search".source = pkgs.fetchFromGitHub {
        owner = "trygveaa";
        repo = "kitty-kitten-search";
        rev = "992c1f3d220dc3e1ae18a24b15fcaf47f4e61ff8";
        hash = "sha256-Xy4dH2fzEQmKfqhmotVDEszuTqoISONGNfC1yfcdevs=";
      };
      "kitty/pyrightconfig.json".source = json.generate "pyrightconfig.json" {
        extraPaths = [ "../../src/github.com/kovidgoyal/kitty" ]; # src-get kovidgoyal/kitty
      };
    }
  );

  home = mkIf cfg.enable {
    packages =
      with pkgs;
      concatLists [
        [
          (writeShellScriptBin "kdiff" ''kitten diff "$@"'')
          (writeShellScriptBin "kssh" ''kitten ssh "$@"'')
          (writeShellScriptBin "icat" ''kitten icat "$@"'')
        ]
        (optional pkgs.stdenv.isLinux (writeShellScriptBin "x-terminal-emulator" ''exec kitty "$@"''))
      ];

    shellAliases = {
      rg = "rg --hyperlink-format=kitty";
    };

    activation = {
      kittyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir $VERBOSE_ARG -p "${config.xdg.configHome}/kitty"

        _kitty_grab="${config.xdg.configHome}/kitty/kitty_grab"
        _git="${pkgs.git}/bin/git"

        if ! [ -d "$_kitty_grab" ]; then
          run $_git clone $VERBOSE_ARG "https://github.com/loganlinn/kitty_grab.git" "$_kitty_grab"
        else
          if ! $_git -C "$_kitty_grab" diff --quiet HEAD 2>/dev/null; then
            warnEcho "kitty_grab: dirty worktree, skipping update"
          elif _branch="$($_git -C "$_kitty_grab" symbolic-ref --short HEAD 2>/dev/null || true)" && [ "$_branch" != "main" ]; then
            warnEcho "kitty_grab: not on main (on '$_branch'), skipping update"
          else
            run $_git -C "$_kitty_grab" fetch $VERBOSE_ARG origin main
            run $_git -C "$_kitty_grab" merge --ff-only origin/main
          fi
        fi
      '';
    };
  };
}
