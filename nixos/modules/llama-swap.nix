{
  pkgs,
  ...
}: let
  llama-cpp = pkgs.llama-cpp.override {cudaSupport = true;};
in {
  services.llama-swap = {
    listenAddress = "0.0.0.0";
    openFirewall = true;
    settings = {
      logLevel = "info";
    };
  };

  # llama-server available in service PATH for model cmd strings
  systemd.services.llama-swap.path = [llama-cpp];
}
