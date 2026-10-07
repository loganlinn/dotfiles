{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.ghostty = {
    package = lib.mkDefault (
      if pkgs.stdenv.isLinux
      then pkgs.ghostty
      else null
    );
    installVimSyntax = config.programs.ghostty.package != null;
    enableZshIntegration = config.programs.ghostty.package != null;
    installBatSyntax = config.programs.ghostty.package != null && config.programs.bat.enable;
  };
}
