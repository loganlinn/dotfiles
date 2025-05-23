{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.browsers;

  hasUnescapedQuote = s: (strings.match ''.*[^\]".*'' s) != null;
in {
  options.modules.desktop.browsers = {
    default = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    alternate = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config = {
    home.sessionVariables = attrsets.mergeAttrsList [
      (optionalAttrs (cfg.default != null) {
        BROWSER = assert assertMsg (!hasUnescapedQuote cfg.default)
        "must escape quotes for session variable";
          cfg.default;
      })
      (optionalAttrs (cfg.alternate != null) {
        BROWSER_ALT = assert assertMsg (!hasUnescapedQuote cfg.alternate)
        "must escape quotes for session variable";
          cfg.alternate;
      })
      (optionalAttrs config.programs.firefox.enable {
        MOZ_USE_XINPUT2 = "1";
        MOZ_DISABLE_RDD_SANDBOX = "1"; # Required to use va-api with Firefox
      })
    ];

    programs.firefox = {
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
  };
}
