{
  config,
  lib,
  pkgs,
  ...
}:

{
  home-manager.sharedModules = [
    {
      home.packages = with pkgs; [
        awscli2
      ];
      programs.bash.initExtra = ''
        complete -C '${pkgs.awscli2}/bin/aws_completer' aws
      '';
      programs.zsh.initExtra = ''
        complete -C '${pkgs.awscli2}/bin/aws_completer' aws
      '';
    }
  ];
}
