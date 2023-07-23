{config, ...}: {
  imports = [
    ../../../home/firefox.nix
  ];

  # TODO: some of this is assuming nvidia
  config = {
    programs.firefox = {
      enable = true;
      profiles."${config.my.user.name}".settings = {
        # Enable WebRTC VA-API decoding support
        # https://bugzilla.mozilla.org/show_bug.cgi?id=1646329
        # https://github.com/elFarto/nvidia-vaapi-driver/
        "gfx.canvas.accelerated" = true;
        "gfx.webrender.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "media.av1.enabled" = false;
        "media.ffmpeg.low-latency.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        # Disable Firefox's VP8/VP9 software decoder to use VA-API
        "media.ffvpx.enabled" = false;
        "media.hardware-video-decoding.enabled" = true;
      };
    };

    home.sessionVariables.MOZ_USE_XINPUT2 = "1";
    home.sessionVariables.MOZ_DISABLE_RDD_SANDBOX = "1"; # Required to use va-api with Firefox
  };
}
