{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git-stack
  ];

  programs.git = {
    aliases = {
      amend = "stack amend";
      run = "stack run";
      next = "stack next";
      prev = "stack previous";
      reword = "stack reword";
      sync = "stack sync";
    };
  };
}
