{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    forwardAgent = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/%r@%h:%p";
    controlPersist = "60m";
    serverAliveInterval = 120;
    includes = ["${config.home.homeDirectory}/.ssh/config.local"];
    matchBlocks = {
      "fire.walla" = {
        user = "pi";
      };
    };
    extraConfig = ''
      TCPKeepAlive yes
      HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256
    '';
  };
}
