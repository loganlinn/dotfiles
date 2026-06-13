{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh.initContent = lib.mkIf config.programs.direnv.enable ''
    function direnv-export() {
      local format=''${1:-json}
      local path_to_rc=''${2:-$PWD}
      env -i HOME="$HOME" PATH="$PATH" RENDER_DIRENV="''${path_to_rc?}" \
          direnv export "''${format?}" 2>/dev/null
    }
  '';

  programs.direnv = {
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    silent = false;
    stdlib = '''';
    # https://github.com/direnv/direnv/blob/master/man/direnv.toml.1.md
    config = {
      global = {
        warn_timeout = "10s";
        hide_env_diff = true;
      };
      whitelist = {
        prefix = [
          "${config.my.flakeDirectory}"
          "~/src/github.com/${config.my.github.username}"
        ];
      };
    };
  };
}
