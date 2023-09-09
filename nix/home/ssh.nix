{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    hashKnownHosts = true;
    forwardAgent = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/%C";
    controlPersist = "60m";
    serverAliveInterval = 120;
    includes = [ "${config.home.homeDirectory}/.ssh/config.local" ];
    matchBlocks = {
      "fire.walla" = {
        user = "pi";
      };
    };
    extraConfig = ''
      TCPKeepAlive yes

      Host *
        IdentityAgent ~/.1password/agent.sock
    '';
  };
}
