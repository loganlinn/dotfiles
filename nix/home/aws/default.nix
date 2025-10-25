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

  my.shellScripts = {
    aws-secretctl = {
      text = lib.readFile ./bin/aws-secretctl;
      bashOptions = [ ]; # allow script to handle
    };
    aws-secretctl-list = {
      text = lib.readFile ./bin/aws-secretctl-list;
      bashOptions = [ ]; # allow script to handle
    };
    aws-secretctl-select = {
      runtimeInputs = with pkgs; [ gum ];
      text = lib.readFile ./bin/aws-secretctl-select;
      bashOptions = [ ]; # allow script to handle
    };
    aws-secretctl-get = {
      text = lib.readFile ./bin/aws-secretctl-get;
      bashOptions = [ ]; # allow script to handle
    };
    aws-secretctl-delete = {
      runtimeInputs = with pkgs; [ gum ];
      text = lib.readFile ./bin/aws-secretctl-delete;
      bashOptions = [ ]; # allow script to handle
    };
    aws-secretctl-edit = {
      runtimeInputs = with pkgs; [
        gum
        moreutils
      ];
      text = lib.readFile ./bin/aws-secretctl-edit;
      bashOptions = [ ]; # allow script to handle
    };
  };
}
