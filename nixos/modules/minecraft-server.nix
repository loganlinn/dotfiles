{ config, lib, pkgs, ... }:

let cfg = config.modules.minecraft-server; in
{
  options.modules.minecraft-server = with lib; {
    enable = mkEnableOption "creepers";
  };

  config = {
    services.minecraft-server = {
      enable = true;
      eula = true;
      declarative = true;
      # more info: https://minecraft.gamepedia.com/Server.properties#server.properties
      serverProperties = lib.mkOptionDefault {
        server-port = 25565;
        gamemode = "survival";
        motd = "welcome, ~/";
        max-players = 5;
        # enable-rcon = true;
        # "rcon.password" = "hunter2";
      };
    };
  };
}
