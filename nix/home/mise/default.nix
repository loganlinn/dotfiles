{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf getExe mkOrder;
  cfg = config.programs.mise;
  miseExe = if cfg.package != null then getExe cfg.package else "mise";
in {

  home.shellAliases = mkIf cfg.enable {
    m = "mise";
    mr = "mise run";
    mx = "mise exec";
  };

    programs = mkIf cfg.enable {
      mise = {
        package = pkgs.runCommand "mise-bootstrap" { meta.mainProgram = "mise"; } ''install -Dm755 ${./bootstrap.sh} $out/bin/mise'';
        enableZshIntegration = false;
        enableBashIntegration = false;
        enableFishIntegration = false;
        enableNushellIntegration = false;
        # globalConfig = {};
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

      bash.initExtra =
        let
          # TODO: Upstream to nixpkgs
          bashCompletion = pkgs.runCommand "mise-bash-completion.bash" { } ''
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
            pkgs.runCommand "mise-nushell-config.nu" { } ''
              ${miseExe} activate nu > $out
            ''
          }
        '';
      };
    };
}
