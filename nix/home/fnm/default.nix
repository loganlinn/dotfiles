{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options = {
    programs.fnm = {
      # enable = mkEnableOption "fnm (node.js version manager)";
      package = mkPackageOption pkgs "fnm" {};
      settings = mkOption {
        type = types.attrs;
        default = {
          use-on-cd = false;
          version-file-strategy = "recursive";
          corepack-enabled = true;
        };
      };
    };
  };

  config = {
    home.packages = [config.programs.fnm.package];

    programs.zsh.initContent = ''
      # initialize fnm (node.js version manager)
      eval "$(${lib.getExe pkgs.fnm} env --shell zsh ${cli.toCommandLineShellGNU {} config.programs.fnm.settings})" \
        && if ! [[ -f $${XDG_CACHE_HOME:=$HOME/.cache}/zsh/functions/_fnm ]]; then
          typeset -g -A _comps
          autoload -Uz _fnm
          _comps[fnm]=_fnm
        fi | true
      mkdir -p "$XDG_CACHE_HOME/zsh/functions"
      ${lib.getExe pkgs.fnm} completions --shell=zsh >| "$XDG_CACHE_HOME/zsh/functions/_fnm" &|
    '';

    programs.bash.initExtra = ''
      # initialize fnm (node.js version manager)
      eval "$(${lib.getExe pkgs.fnm} env --shell bash ${cli.toCommandLineShellGNU {} config.programs.fnm.settings})"
    '';
  };
}
