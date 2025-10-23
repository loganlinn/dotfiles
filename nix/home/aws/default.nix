{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    aws-sso-cli # https://github.com/synfinatic/aws-sso-cli
    awscli2
    awslogs # CloudWatch logs for humans
    awsls
    awsrm
    e1s # ECS like k9s
  ];

  programs.zsh.initContent = lib.mkAfter (lib.readFile ./aws-sso.zsh);
}
