{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    forwardAgent = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/%C";
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
      HostKeyAlgorithms ${lib.concatStringsSep "," [
        "ssh-ed25519-cert-v01@openssh.com"
        "ssh-rsa-cert-v01@openssh.com"
        "ssh-ed25519"
        "ssh-rsa"
        "ecdsa-sha2-nistp256-cert-v01@openssh.com"
        "ecdsa-sha2-nistp521-cert-v01@openssh.com"
        "ecdsa-sha2-nistp384-cert-v01@openssh.com"
        "ecdsa-sha2-nistp521"
        "ecdsa-sha2-nistp384"
        "ecdsa-sha2-nistp256"
        "hmac-sha2-256"
        "hmac-sha2-512"
        "hmac-sha1"
        "hmac-sha1-96"
        "hmac-md5"
        "hmac-md5-96"
        "hmac-ripemd160"
        "hmac-ripemd160@openssh.com"
      ]}

      Host *
        IdentityAgent ~/.1password/agent.sock
    '';
  };
}
