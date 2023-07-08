{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.my.shell;

in
{
  options.my.shell = {
    initExtra = mkOption {
      type = types.lines;
      description = "Extra commands that should be added to <filename>.zshrc</filename> and <filename>.zshrc</filename>.";
      default = "";
    };
  };

  config = {
    home.shellAliases = import ./aliases.nix;
    home.packages = with pkgs; [
      bashInteractive
    ];
    programs.bash.initExtra = cfg.initExtra;
    programs.zsh.initExtra = cfg.initExtra;
    my.shell.initExtra = ''
      ${readFile ./which.sh}

      ${readFile ./op.sh}

      source ${./../../../bin/src-get}
    '';
  };
}
