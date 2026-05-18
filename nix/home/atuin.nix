{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.atuin = {
    daemon.enable = lib.mkDefault config.programs.atuin.enable;
    settings = {
      auto_sync = lib.mkDefault false;
      dialect = "us";
      enter_accept = lib.mkDefault false;
      inline_height = lib.mkDefault 25;
      invert = lib.mkDefault false;
      keys.prefix = "s";
      prefers_reduced_motion = true;
      style = "compact";
      update_check = false;
    };
    flags = [
      "--disable-up-arrow"
    ];
    enableZshIntegration = lib.mkDefault true;
    enableBashIntegration = lib.mkDefault true;
  };

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

}
