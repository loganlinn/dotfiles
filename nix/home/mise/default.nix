{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.mise;
in
{
  programs.mise = {
    enable = lib.mkDefault true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  home.shellAliases = lib.mkIf cfg.enable {
    m = "mise";
    mr = "mise run";
    mx = "mise exec";
  };

  programs.zsh.initContent = lib.mkIf cfg.enable ''
    function +mise { eval "$(mise activate zsh "$@")"; }

    function mxx () {
      emulate -L zsh

      local tool_spec=$1
      if [[ -z $tool_spec ]]; then
        print -r -- "usage: mxx tool[@version] [args...]" >&2
        return 2
      fi
      shift

      local tool=''${tool_spec%%@*}
      mise exec "$tool_spec" -- "$tool" "$@"
    }
  '';
}
