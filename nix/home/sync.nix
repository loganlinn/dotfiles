{
  config,
  pkgs,
  self,
  ...
}: {
  services.syncthing = {
    enable = true;
  };
}
