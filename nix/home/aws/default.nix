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
      # {
      #   name = "aws-help-linkify";
      #   src = ./help-linkify;
      # }
    ];
    initContent = lib.mkMerge [
      (lib.mkAfter (lib.readFile ./aws-sso.zsh))
      (lib.mkAfter ''
        @aws() {
          emulate -L zsh

          local profile
          profile=$(
            aws configure list-profiles --output text |
              ${lib.getExe pkgs.gum} choose \
                --header="Choose profile:" \
                --ordered \
                --selected="''${1:-''${AWS_PROFILE:-default}}" \
                --select-if-one
          ) || return $?

          export AWS_PROFILE=$profile

          ${lib.getExe pkgs.gum} log --structured export AWS_PROFILE "$AWS_PROFILE"
        }
      '')
    ];
  };
}
