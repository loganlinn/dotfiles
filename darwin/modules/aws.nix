{
  config,
  lib,
  ...
}: {
  imports = [
    {
      homebrew.taps = ["aws/tap"];
      homebrew.brews = ["aws/tap/copilot-cli"];
    }
    # Utility for AWS CloudWatch Logs <https://github.com/TylerBrock/saw>
    {
      homebrew.taps = ["TylerBrock/saw"];
      homebrew.brews = ["TylerBrock/saw/saw"];
    }
  ];
  home-manager.sharedModules = lib.singleton (
    {pkgs, ...}: {
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
  );
}
