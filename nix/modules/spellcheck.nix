{ self, config, lib, pkgs, ... }:

with lib;

let

  cfg = config.modules.spellcheck;

in
{
  options.modules.spellcheck = with types ;{
    enable = mkEnableOption "spell-checking backends";
    aspell.enable = (mkEnableOption "aspell") // { default = true; };
    hunspell.enable = (mkEnableOption "hunspell") // { default = true; };
  };

  config = mkIf cfg.enable {

    home.packages =
      (optional cfg.aspell.enable (
        pkgs.aspellWithDicts (ds: with ds; [
          en
          en-computers
          en-science
        ])))
      ++
      (optional cfg.hunspell.enable pkgs.hunspell)
    ;

  };
}
