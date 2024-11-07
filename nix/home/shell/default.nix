{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.my;
in
{
  imports = [
    ../bash
    ../zsh
  ];

  options.my = {
    shellInitExtra = mkOption {
      type = types.lines;
      description = "Extra commands that should be added to <filename>.zshrc</filename> and <filename>.zshrc</filename>.";
      default = "";
    };
  };

  config = {
    home.shellAliases = {
      "'..'" = "cd ..";
      "'...'" = "cd ...";
      l = "ls -lah";
      mkd = "mkdir -p";

      prunedirs = "fd -td -te -x rmdir -v";

      epoch = "date +%s";
      today = "date -Idate -dnow";
    };

    programs.bash.initExtra = cfg.shellInitExtra;

    programs.zsh.initExtra = cfg.shellInitExtra;

    my.shellInitExtra = ''
      ${readFile ./which.sh}

      ${readFile ./kubernetes.sh}

      ${readFile ./op.sh}

      source ${./../../../bin/src-get}
    '';
  };
}
