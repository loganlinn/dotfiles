{
  config,
  pkgs,
  self,
  ...
}: {
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };
}
