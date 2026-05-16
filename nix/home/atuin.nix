{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "atuin-restart";
      runtimeInputs = with pkgs;
        [coreutils]
        ++ lib.optional stdenv.isLinux systemd;
      text = ''
        socket_path="''${XDG_DATA_HOME:-$HOME/.local/share}/atuin/daemon.sock"
        pid_file="''${XDG_DATA_HOME:-$HOME/.local/share}/atuin/atuin-daemon.pid"

        rm -f "$socket_path" "$pid_file"

        case "$(uname -s)" in
          Darwin)
            launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.atuin-daemon"
            ;;
          Linux)
            systemctl --user restart atuin-daemon
            ;;
          *)
            echo >&2 "atuin-restart: unsupported OS: $(uname -s)"
            exit 1
            ;;
        esac
      '';
    })
  ];

  programs.atuin = {
    daemon.enable = lib.mkDefault config.programs.atuin.enable;
    settings = {
      auto_sync = false;
      dialect = "us";
      enter_accept = false;
      inline_height = 20;
      invert = true;
      keys.prefix = "s";
      prefers_reduced_motion = true;
      style = "compact";
      update_check = false;
    };
    flags = [
      "--disable-up-arrow"
    ];
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
