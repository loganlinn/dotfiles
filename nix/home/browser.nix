{ config, lib, pkgs, ... }:

let
  chromeExtensions = [
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
    "kcabmhnajflfolhelachlflngdbfhboe" # Spoof Timezone
    "edibdbjcniadpccecjdfdjjppcpchdlm" # I still don't care about cookies
    "cfohepagpmnodfdmjliccbbigdkfcgia" # Location Guard
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
    "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma integration
  ];
in {
  programs.chromium = {
    enable = true;
    extensions = chromeExtensions;
  };

  programs.google-chrome.enable = true;

  programs.google-chrome-beta.enable = true;

  home.sessionVariables.MOZ_USE_XINPUT2 = "1";
  # Required to use va-api with Firefox
  home.sessionVariables.MOZ_DISABLE_RDD_SANDBOX = "1";

  programs.firefox = {
    enable = true;
    # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #   ublock-origin
    #   vim-vixen
    # ];
    profiles = {
      logan = {
        id = 0;
        settings =
          {
            # General settings
            "app.update.auto" = false;
            "app.update.checkInstallTime" = false;
            "browser.aboutConfig.showWarning" = false;
            "browser.aboutwelcome.enabled" = false;
            "browser.ctrlTab.recentlyUsedOrder" = false;
            "browser.fixup.alternate.enabled" = false;
            "browser.preferences.defaultPerformanceSettings.enabled" = false;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.startup.homepage" = "about:blank";
            "browser.tabs.loadBookmarksInBackground" = true;
            "browser.tabs.tabmanager.enabled" = true;
            "browser.uitour.enabled" = false;
            "browser.urlbar.doubleClickSelectsAll" = false;
            "general.smoothScroll" = true;
            "signon.rememberSignons" = false;

            # Privacy settings
            "privacy.donottrackheader.enabled" = true;
            "privacy.popups.showBrowserMessage" = false;

            # Disable built-in Pocket extension
            "extensions.pocket.enabled" = false;
            "extensions.pocket.onSaveRecs" = false;

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

            # Disable telemetry, sponsored content, and other creepy shit.
            "app.normandy.enabled" = false;
            "app.normandy.api_url" = "";
            "app.shield.optoutstudies.enabled" = true;
            "beacon.enabled" = false;
            "breakpad.reportURL" = "";
            "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "browser.send_pings" = false;
            "browser.send_pings.require_same_host" = true;
            "browser.tabs.crashReporting.sendReport" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            "datareporting.healthreport.service.enabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "network.allow-experiments" = false;
            "toolkit.coverage.endpoint.base" = "";
            "toolkit.coverage.opt-out" = true;
            "toolkit.telemetry.coverage.opt-out" = true;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.healthping.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.prompted" = 2;
            "toolkit.telemetry.rejected" = true;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.server" = "";
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.unifiedIsOptIn" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            # https://arxiv.org/abs/1810.07304
            "security.ssl.disable_session_identifiers" = true;
            "security.ssl.errorReporting.automatic" = false;
            "security.ssl.errorReporting.enabled" = false;
            # Disable some JS/DOM APIs
            "dom.battery.enabled" = false;
            "dom.vr.enabled" = false;
            "dom.enable_performance" = false;
            "device.sensors.enabled" = false;
            "dom.gamepad.enabled" = false;
          };
        search = {
          force = true;
          default = "Google";
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];
              icon =
                "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@pkgs" ];
            };
            "NixOS Wiki" = {
              urls = [{
                template = "https://nixos.wiki/index.php?search={searchTerms}";
              }];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nix" ];
            };
            "Bing".metaData.hidden = true;
            "Google".metaData.alias =
              "@g"; # builtin engines only support specifying one additional alias
          };
        };
      };
    };
  };

  programs.librewolf.enable = true;
}
