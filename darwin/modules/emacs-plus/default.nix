{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.emacs-plus;
  caskType = with types; either str (attrsOf anything); # options.homebrew.casks.type.nestedTypes.elemType;
in
{
  options = {
    programs.emacs-plus = {
      enable = mkEnableOption "emacs-plus";
      cask = mkOption {
        type = caskType;
        default = "d12frosted/emacs-plus/emacs-plus-app";
        example = literalExpression ''
          {
            name = "d12frosted/emacs-plus/emacs-plus@31";
            args = ["with-native-comp" "with-xwidgets" "with-c9rgreen-sonoma-icon"];
          }
        '';
        description = "Cask to install from d12frosted/emacs-plus tap";
      };
    };
  };

  config = mkIf cfg.enable {
    homebrew.enable = true;
    homebrew.casks = [ cfg.cask ];
    homebrew.brews = [
      "gcc"
      "coreutils"
      "cmake" # :term vterm
      "libtool" # :term vtern
      "pngpaste" # :lang org
    ];
    environment.systemPackages = with pkgs; [
      fd
      git
      hunspell
      ripgrep
      (writeShellScriptBin "magit" (readFile ../../../bin/magit))
    ];
  };
}
