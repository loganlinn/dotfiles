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
      # https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH-
      "fire.walla" = {
        user = "pi";
      };
      # https://remarkable.guide/guide/access/ssh.html#connecting-over-usb
      "remarkable" = {
        user = "root";
        hostname = "10.11.99.1";
        # identityFile = [ "~/.ssh/id_rsa_remarkable" ];
        extraOptions = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
          HostKeyAlgorithms = "+ssh-rsa";
        };
      };
    };
    extraConfig = ''
      TCPKeepAlive yes
      IdentityAgent ~/.1password/agent.sock
    '';
  };
}
