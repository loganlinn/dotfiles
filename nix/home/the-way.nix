{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.the-way;
in {
  options.programs.the-way = {
    enable = mkEnableOption "the-way";

    package = mkOption {
      type = types.package;
      default = pkgs.the-way;
      defaultText = literalExpression "pkgs.the-way";
      description = "the-way package to install.";
    };

    enableBashIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Bash integration.
      '';
    };

    enableZshIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Zsh integration.
      '';
    };

    enableFishIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Fish integration.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
       function cmdsave() {
         PREV=$(echo "$(history | tail -n2 | head -n1)" | sed 's/[0-9]* //')
         sh -c "${cfg.package}/bin/the-way cmd "$(printf %q "$PREV")""
       }

      function cmdsearch() {
        BUFFER=$(${cfg.package}/bin/the-way search --stdout --languages="sh")
        bind '"\e[0n": "'"$BUFFER"'"'; printf '\e[5n'
      }
    '';

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
      function cmdsave() {
        PREV=$(fc -lrn | head -n 1)
        sh -c "${cfg.package}/bin/the-way cmd "$(printf %q "$PREV")""
      }

      function cmdsearch() {
        BUFFER=$(${cfg.package}/bin/the-way search --stdout --languages="sh")
        print -z $BUFFER
      }
    '';

    programs.fish.shellInit = mkIf cfg.enableFishIntegration ''
      function cmdsave
        set line (echo $history[1])
        ${cfg.package}/bin/the-way cmd $line
      end

      function cmdsearch
        commandline (${cfg.package}/bin/the-way search --languages=sh --stdout)
      end
    '';
  };
}
