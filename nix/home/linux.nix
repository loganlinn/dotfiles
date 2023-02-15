{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
      sysz
      trash-cli
      (writeShellScriptBin ''capslock'' ''${xdotool} key Caps_Lock'')
      (writeShellScriptBin ''CAPSLOCK'' ''${xdotool} key Caps_Lock'') # just in case ;)
    ];

  # requires systemd
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = lib.mkDefault 86400;
    maxCacheTtl = lib.mkDefault 86400;
    pinentryFlavor = lib.mkDefault "gtk2";
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
