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
    # mise.toml deploys config/direnv/direnv.toml; leave that file unmanaged here.
  };
}
