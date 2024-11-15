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
    shellScripts = mkOption {
      description = ''
        See https://nixos.org/manual/nixpkgs/unstable/#trivial-builder-writeShellApplication
      '';
      type = types.attrsOf (import ./shellApplication.nix { inherit pkgs lib; });
    };
  };

  config = {
    home.packages = catAttrs "package" (attrValues config.my.shellScripts);

    home.shellAliases = {
      "'..'" = "cd ..";
      "'...'" = "cd ...";
      l = "ls -lah";
      mkd = "mkdir -p";
      prunedirs = "fd -td -te -x rmdir -v";
      epoch = "date +%s";
      rg-ip = ''rg '((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}' '';
      woman = "man";
      termkeys = "infocmp -L1";
      envz = "printenv | fzf ";
    };

    programs.bash.initExtra = cfg.shellInitExtra;

    programs.zsh.initExtra = cfg.shellInitExtra;

    my.shellScripts = {
      today.text = ''
        # shellcheck disable=SC2145
        exec date -Idate -d"now $@"
      '';
    };

    my.shellInitExtra = ''
      source ${./../../../bin/src-get}
    '';
  };
}
