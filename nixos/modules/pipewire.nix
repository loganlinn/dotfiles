{pkgs, ...}: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false; # not needed atm
  };

  hardware.pulseaudio.enable = false; # handled by/conflicts with services.pipewire

  security.rtkit.enable = true; # recommended for pipewire

  xdg.portal.enable = true; # needed by pipewire

  environment.systemPackages = with pkgs; [
    alsa-utils # arecord
    cava
  ];
}
