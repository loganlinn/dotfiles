{
  config,
  lib,
  ...
}: {
  services.open-webui = {
    enable = true;
    port = 3000;
    openFirewall = false;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
      # disable open-webui bundled ollama — we manage it separately
      ENABLE_OLLAMA_API = "true";
      WEBUI_AUTH = "true";
    };
  };
}
