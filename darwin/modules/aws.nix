{
  config,
  lib,
  ...
}:
{
  home-manager.sharedModules = lib.singleton (
    { pkgs, ... }:
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
        copilot-cli # ECS like heroku/fly
        e1s # ECS like k9s
      ];
    }
  );
}
