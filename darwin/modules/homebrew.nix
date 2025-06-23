{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.homebrew.enable {
    environment.variables = {
      HOMEBREW_NO_ANALYTICS = "1";
    };

    homebrew = {
      caskArgs.no_quarantine = true;
    };

    programs.zsh = {
      interactiveShellInit = ''
        # Tell zsh how to find brew installed completions
        if [[ -v HOMEBREW_PREFIX ]]; then
          fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
        fi
      '';
    };
  };
}
