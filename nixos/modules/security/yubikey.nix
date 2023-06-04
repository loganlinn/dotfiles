{pkgs, ...}: {
  # services.yubikey-agent.enable = true;

  services.pcscd.enable = true; # for yubikey smartcard

  environment.systemPackages = with pkgs; [
    yubikey-personalization
  ];
}
