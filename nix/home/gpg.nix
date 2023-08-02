{ config, lib, pkgs, ... }:

{
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.systemd;
    enableSshSupport = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultCacheTtl = lib.mkDefault 86400;
    maxCacheTtl = lib.mkDefault 86400;
    pinentryFlavor = "tty";
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
