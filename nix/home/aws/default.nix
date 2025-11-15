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
    gum # for aws-secretctl interactive selection
    jq # for aws-secretctl-edit SSM parameter parsing
    moreutils # for vipe in aws-secretctl-edit
  ];

  home.sessionPath = [
    "${config.my.flakeDirectory}/nix/home/aws/bin"
  ];

  programs.zsh = {
    plugins = [
      {
        name = "aws-help-linkify";
        src = ./help-linkify;
      }
    ];
    initContent = lib.mkAfter (lib.readFile ./aws-sso.zsh);
  };
}
