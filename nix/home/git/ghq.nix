{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    ghq
  ];

  programs.git = {
    settings = {
      ghq.root = config.my.userDirs.code;
      ghq.user = config.my.github.username;
    };
  };
}
