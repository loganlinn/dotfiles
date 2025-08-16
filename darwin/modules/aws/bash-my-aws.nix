{
  config,
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton (
    { pkgs, ... }:
    let
      cfg = config.my.bash-my-aws;
      bash-my-aws-shell-init = ''
        bash-my-aws() {
          export BMA_HOME=$${BMA_HOME:-${pkgs.bash-my-aws}}
          source "$BMA_HOME/aliases" &&
          source "$BMA_HOME/bash_completion.sh" &&
          echo "Loaded bash-my-aws"
        }
      '';
    in
    {
      options = {
        bash-my-aws = {
          enable = lib.mkEnableOption "bash-my-aws";
        };
      };
      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          bash-my-aws
        ];
        programs.bash.initExtra = ''
          ${bash-my-aws-shell-init}
        '';
        programs.zsh = {
          completionInit = ''
            complete -C '${pkgs.awscli2}/bin/aws_completer' aws
          '';
          initContent = ''
            ${bash-my-aws-shell-init}
          '';
        };
      };
    }
  );
}
