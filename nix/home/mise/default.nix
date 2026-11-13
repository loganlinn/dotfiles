{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOrder;
  cfg = config.programs.mise;
  miseExe = lib.escapeShellArg "${config.my.flakeDirectory}/bin/mise";
in {
  home = mkIf cfg.enable {
    extraActivationPath = with pkgs; [
      curl
      gnutar
      gzip
    ];

    shellAliases = {
      m = "mise";
      mr = "mise run";
      mx = "mise exec";
    };
    activation.mise-dotfiles = lib.hm.dag.entryAfter ["linkGeneration"] ''
      run ${miseExe} \
        --cd ${lib.escapeShellArg config.my.flakeDirectory} \
        dotfiles apply --yes
    '';
  };

  programs = mkIf cfg.enable {
    mise = {
      # The checked-in bin/mise bootstrap owns the mise version and installation.
      package = null;

      enableZshIntegration = false;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
    };

    zsh = {
      initContent = mkOrder 2000 ''
        eval "$(${miseExe} activate zsh)"
      '';

      siteFunctions = {
        "+mise" = ''
          eval "$(${miseExe} activate zsh "$@")"
        '';
        "mxx" = ''
          emulate -L zsh

          local tool_spec=$1
          if [[ -z $tool_spec ]]; then
            print -r -- "usage: mxx tool[@version] [args...]" >&2
            return 2
          fi
          shift

          local tool=''${tool_spec%%@*}
          mise exec "$tool_spec" -- "$tool" "$@"
        '';
      };
    };

    bash.initExtra = let
      # TODO: Upstream to nixpkgs
      bashCompletion = pkgs.runCommand "mise-bash-completion.bash" {} ''
        ${miseExe} completion bash --include-bash-completion-lib > $out
      '';
    in
      mkIf (cfg.enableBashIntegration && cfg.package != null) ''
        eval "$(${miseExe} activate bash)"
        source ${bashCompletion}
      '';

    fish.interactiveShellInit = mkIf (cfg.enableFishIntegration && cfg.package != null) ''
      ${miseExe} activate fish | source
    '';

    nushell = mkIf (cfg.enableNushellIntegration && cfg.package != null) {
      extraConfig = ''
        use ${
          pkgs.runCommand "mise-nushell-config.nu" {} ''
            ${miseExe} activate nu > $out
          ''
        }
      '';
    };
  };
}
