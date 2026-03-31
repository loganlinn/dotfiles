{
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    openFirewall = false; # only local access
  };
}
