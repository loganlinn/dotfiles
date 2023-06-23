{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  programs.mpv = {
    enable = isLinux;
    scripts = with pkgs.mpvScripts; [
      # autoload # loads playlist entries
      mpris # media keys
      thumbnail # in OSC seekbar
      sponsorblock
    ];
    config = {
      # REF: https://github.com/hl2guide/better-mpv-config/blob/ff34dca21bd7689585af8b6fbe53c7abbada4873/mpv_v3/mpv.conf
      # REF: https://github.com/Argon-/mpv-config/blob/master/mpv.conf
      # REF: https://github.com/Zabooby/mpv-config
      # REF: https://gist.github.com/igv
      # ===== General =====
      hls-bitrate = "max"; # uses max quality for HLS streams
      prefetch-playlist = true; # prefetches the playlist
      snap-window = true; # Enables windows snapping for Windows 10, 11
      # priority = "high"; # Makes PC prioritize MPV for allocating resources
      cache= true;
      osc = false;
      hwdec = "auto-safe";
      hwdec-codecs = "all";
      autofit = "1080";
      # ===== Audio =====
      volume-max = 100; # maximum volume in %, everything above 100 results in amplification
      volume = 70; # default volume, 100 = unchanged
      # ===== Video =====
      vo = "gpu-next"; # Sets the video out to an experimental video renderer based on libplacebo
      force-seekable = true;
      # ===== RAM =====
      demuxer-max-bytes = "20M"; # sets fast seeking
      demuxer-max-back-bytes = "20M"; # sets fast seeking
      # ===== Term =====
      cursor-autohide = 100; # autohides the cursor after X millis
      cursor-autohide-fs-only = true; # don't autohide the cursor in window mode, only fullscreen
      msg-color = true; # color log messages on terminal
      msg-module = true; # prepend module name to log messages
      term-osd-bar = true; # displays a progress bar on the terminal
      # ===== OSD =====
      osd-bar-align-y = -1; # progress bar y alignment (-1 top, 0 centered, 1 bottom)
      osd-bar-h = 2; # height of osd bar as a fractional percentage of your screen height
      osd-bar-w = 99; # width of " " "
      osd-border-color = "#DD322640"; # ARGB format
      osd-border-size = 2; # size for osd text and progress bar
      osd-color = "#FFFFFFFF"; # ARGB format
      osd-duration = 2500; # hide the osd after X ms
      osd-font-size = 32;
      # osd-status-msg = concatStrings [
      #   "\${time-pos} / \${duration}"
      #   "\${?percent-pos:  (\${percent-pos}%)}"
      #   "\${?frame-drop-count:\${!frame-drop-count==0:  Dropped: \${frame-drop-count}}}"
      #   "\n"
      #   "\${?chapter:Chapter: \${chapter}}"
      # ];
      # ===== Shaders =====
      # TODO https://github.com/hl2guide/better-mpv-config/blob/master/mpv_v3/mpv_shaders.conf
      # ===== Subtitles =====
      # TODO https://github.com/hl2guide/better-mpv-config/blob/master/mpv_v3/mpv_subtitles.conf
    } // optionalAttrs config.programs.yt-dlp.enable {
      script-opts = "ytdl_hook-ytdl_path=${config.programs.yt-dlp.package}/bin/yt-dlp";
      ytdl-format = "bv[height<=1440]+ba/best[height<=1440]/bestvideo+bestaudio/best";
    };

    bindings = {
      "AXIS_DOWN" = "add volume -2";
      "AXIS_UP" = "add volume 2";
      "MBTN_MID" = "cycle pause";
      "MBTN_BACK" = "add chapter -1";
      "MBTN_FORWARD" = "add chapter 1";
      "r" = "playlist-shuffle";
    };

    # defaultProfiles = mkDefault [ "gpu-hq" "interpolation" ];
    # profiles = {
    #   interpolation = {
    #     interpolation = true;
    #     tscale = "box";
    #     tscale-window = "quadric";
    #     tscale-clamp = 0.0;
    #     tscale-radius = 1.025;
    #     video-sync = "display-resample";
    #     blend-subtitles = "video";
    #   };
    #   onetime = {
    #     keep-open = false;
    #   };
    #   nodir = {
    #     sub-auto = false;
    #     audio-file-auto = false;
    #   };
    #   image = {
    #     profile = "nodir";
    #     mute = true;
    #     scale = "ewa_lanczossharp";
    #     background = 0.1;
    #     video-unscaled = true;
    #     title = "\${?media-title:\${media-title}}\${!media-title:No file}";
    #     image-display-duration = "inf";
    #     loop-file = true;
    #     term-osd = "force";
    #     osc = false;
    #     osd-level = 1;
    #     osd-bar = false;
    #     osd-on-seek = false;
    #     osd-scale-by-window = false;
    #   };
    #   "extension.webm" = {
    #     loop-file = "inf";
    #   };
    #   "extension.mp4" = {
    #     loop-file = "inf";
    #   };
    #   "extension.gif" = {
    #     interpolation = "no";
    #   };
    #   "extension.png" = {
    #     video-aspect = "no";
    #   };
    #   "extension.jpg" = {
    #     video-aspect = "no";
    #   };
    #   "extension.jpeg" = {
    #     profile = "extension.jpg";
    #   };
    # };
  };
}
