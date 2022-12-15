{
  config,
  pkgs,
  self,
  lib,
  ...
}: {
  services.emacs = {
    enable = true;
    client = {enable = true;};
    startWithUserSession = true;
  };
}
