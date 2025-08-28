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
        # amazon-ecr-credential-helper
        # aws-gate # Better AWS SSM Session manager CLI client
        # aws-iam-authenticator # EKS auth
        # aws-shell # https://github.com/awslabs/aws-shell
        # aws-spend-summary
        # aws-sso-util # https://github.com/benkehoe/aws-sso-util
        # awsume
        aws-sso-cli # https://github.com/synfinatic/aws-sso-cli
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
