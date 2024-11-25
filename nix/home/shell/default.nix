{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.my;
  shellScriptModule = pkgs.callPackage ./shellScriptModule.nix { };
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
      type = types.attrsOf shellScriptModule;
    };
  };

  config = {
    home.shellAliases = {
      "'..'" = "cd ..";
      "'...'" = "cd ...";
      l = "ls -lah";
      mkd = "mkdir -p";
      epoch = "date +%s";
      rg-ip = ''rg '((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}' '';
      woman = "man";
      termkeys = "infocmp -L1";
      envz = "printenv | fzf ";
    };

    programs.bash.initExtra = cfg.shellInitExtra;

    programs.zsh.initExtra = cfg.shellInitExtra;

    my.shellScripts = {
      prunedir.text = ''
        # finds and destroy empty directories (of empty directories)
        #
        # notes:
        # - not using rmdir --verbose flag to avoid confusing output about
        #   already-deleted paths not found, or soon-to-be-deleted paths not being empty.
        # - print to stdout *after* deleting to check if directory is still there
        #   after rmdir --parents does its thing.
        # - use null-delimited output to avoid issues with filenames containing
        #
        fd --type directory \
           --type empty \
           --absolute-path \
           --exec-batch rmdir --ignore-fail-on-non-empty --parents \; \
           --exec-batch printf '%s\0' \; \
         | while IFS= read -r -d $'\0' dir; do
           if [[ ! -d "$dir" ]]; then
             printf 'removed empty directory: '%s'\n' "$(realpath --relative-to=. --canonicalize-missing "$dir")"
           fi
         done
      '';
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
