{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.hexchat.enable {
    programs.hexchat = {
      enable = true;
      channels."Libera.Chat" = {
        servers = [ "irc.libera.chat" ];
        autojoin = [ "#nixos" ];

        # mkdir -p $XDG_CONFIG_HOME/hexchat/certs
        # op document get hy5sueypnainlye7gcnbskuima >$XDG_CONFIG_HOME/hexchat/certs/client.pem
        # chmod 600 $XDG_CONFIG_HOME/hexchat/certs/client.pem
        loginMethod = "saslExternal";

        realName = "llinn";
        nickname = "llinn";
        nickname2 = "loganlinn";

        options = {
          forceSSL = true;
          useGlobalUserInformation = false;
        };
      };
      overwriteConfigFiles = true;
      settings = { text_font = "Victor Mono 12"; };
      source = pkgs.fetchzip {
        url = "https://dl.hexchat.net/themes/Monokai.hct#Monokai.zip";
        sha256 = "sha256-WCdgEr8PwKSZvBMs0fN7E2gOjNM0c2DscZGSKSmdID0=";
        stripRoot = false;
      };
    };
    home.packages = with pkgs; [ victor-mono ];
  };
}
