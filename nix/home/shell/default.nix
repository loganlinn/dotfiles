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
  shellScriptType = types.coercedTo types.str (text: { inherit text; }) shellScriptModule;
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
      type = types.attrsOf shellScriptType;
    };
  };

  config = {
    # The default for all programs.<PROGRAM>.enable<SHELL>Integration
    # home.shell.enableShellIntegration = true; # TODO

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
      fd = "fd --hyperlink";
    };

    programs.bash.initExtra = cfg.shellInitExtra;

    programs.zsh.initContent = cfg.shellInitExtra;

    my.shellScripts = {
      prunedir.text = ''
        ${pkgs.fd}/bin/fd "''${1-.}" -td -te -a -x ${pkgs.coreutils}/bin/rmdir --parents --verbose --ignore-fail-on-non-empty
      '';
      today.text = ''
        # shellcheck disable=SC2145
        exec date -Idate -d"now $@"
      '';
      harden.text = ''
        # harden a link (convert it to a singly linked file)
        for arg; do
          rnd=$RANDOM
          cp "$arg" "$arg"."$rnd"
          rm "$arg"
          mv "$arg"."$rnd" "$arg"
        done
      '';
    };

    my.shellInitExtra = ''
      source "${config.my.flakeDirectory}/bin/src-get"
    '';
  };
}
