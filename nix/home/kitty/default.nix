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
      enableGitIntegration = true;
      font = config.my.fonts.terminal;
      shellIntegration.enableBashIntegration = true;
      shellIntegration.enableZshIntegration = true;
      shellIntegration.enableFishIntegration = true;
      extraConfig = ''
        include kitty.common.conf
        ${optionalString pkgs.stdenv.isDarwin "kitty.darwin.conf"}
        ${optionalString pkgs.stdenv.isLinux "kitty.linux.conf"}
        include kitty.local.conf
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
          "kitty.common.conf"
          "kitty.darwin.conf"
          "kitty.linux.conf"
          "open-actions.conf"
          "current-theme.conf"
          "diff.conf"
          "choose-files.conf"
          "quick-access-terminal.conf"
          "grab.conf"
          "one.kitty-session"
          "two.kitty-session"
          "three.kitty-session"
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

    home.activation = mkIf cfg.enable {
      kittyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${config.xdg.configHome}/kitty"
        touch "${config.xdg.configHome}/kitty/kitty.local.conf"
        chmod 600 "${config.xdg.configHome}/kitty/kitty.local.conf"
      '';
    };
  }
