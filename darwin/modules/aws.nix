{
  config,
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton (
    { pkgs, ... }:
    let
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
      home.packages = with pkgs; [
        # aws-gate # Better AWS SSM Session manager CLI client
        # aws-iam-authenticator # EKS auth
        # aws-spend-summary
        # aws-sso-cli # https://github.com/synfinatic/aws-sso-cli
        # aws-sso-util # https://github.com/benkehoe/aws-sso-util
        # awsume
        # amazon-ecr-credential-helper
        # aws-shell # https://github.com/awslabs/aws-shell
        awscli2
        awslogs # CloudWatch logs for humans
        awsls
        awsrm
        bash-my-aws
        copilot-cli # ECS like heroku/fly
        e1s # ECS like k9s
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
    }
  );
}
