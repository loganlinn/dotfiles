{
  config,
  lib,
  ...
}:
with lib; let
  images = [
    "image/bmp"
    "image/gif"
    "image/jpeg"
    "image/jpg"
    "image/pjpeg"
    "image/png"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/tiff"
    "image/vnd.wap.wbmp;image/x-icns"
    "image/x-bmp"
    "image/x-gray"
    "image/x-icb"
    "image/x-ico"
    "image/x-pcx"
    "image/x-png"
    "image/x-portable-anymap"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-xbitmap"
    "image/x-xpixmap"
  ];
  urls = [
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xht"
    "application/x-extension-xhtml"
    "application/xhtml+xml"
    "text/html"
    "x-scheme-handler/about"
    "x-scheme-handler/chrome"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/mailto"
    "x-scheme-handler/unknown"
    "x-scheme-handler/webcal"
  ];
  documents = [
    "application/illustrator"
    "application/oxps"
    "application/pdf"
    "application/postscript"
    "application/vnd.comicbook+zip"
    "application/vnd.comicbook-rar"
    "application/vnd.ms-xpsdocument"
    "application/x-bzdvi"
    "application/x-bzpdf"
    "application/x-bzpostscript"
    "application/x-cb7"
    "application/x-cbr"
    "application/x-cbt"
    "application/x-cbz"
    "application/x-dvi"
    "application/x-ext-cb7"
    "application/x-ext-cbr"
    "application/x-ext-cbt"
    "application/x-ext-cbz"
    "application/x-ext-djv"
    "application/x-ext-djvu"
    "application/x-ext-dvi"
    "application/x-ext-eps"
    "application/x-ext-pdf"
    "application/x-ext-ps"
    "application/x-gzdvi"
    "application/x-gzpdf"
    "application/x-gzpostscript"
    "application/x-xzpdf"
    "image/tiff"
    "image/vnd.djvu+multipage"
    "image/x-bzeps"
    "image/x-eps"
    "image/x-gzeps"
  ];
  audioVideo = [
    "application/mxf"
    "application/ogg"
    "application/sdp"
    "application/smil"
    "application/streamingmedia"
    "application/vnd.apple.mpegurl"
    "application/vnd.ms-asf"
    "application/vnd.rn-realmedia"
    "application/vnd.rn-realmedia-vbr"
    "application/x-cue"
    "application/x-extension-m4a"
    "application/x-extension-mp4"
    "application/x-matroska"
    "application/x-mpegurl"
    "application/x-ogg"
    "application/x-ogm"
    "application/x-ogm-audio"
    "application/x-ogm-video"
    "application/x-shorten"
    "application/x-smil"
    "application/x-streamingmedia"
    "audio/3gpp"
    "audio/3gpp2"
    "audio/AMR"
    "audio/aac"
    "audio/ac3"
    "audio/aiff"
    "audio/amr-wb"
    "audio/dv"
    "audio/eac3"
    "audio/flac"
    "audio/m3u"
    "audio/m4a"
    "audio/mp1"
    "audio/mp2"
    "audio/mp3"
    "audio/mp4"
    "audio/mpeg"
    "audio/mpeg2"
    "audio/mpeg3"
    "audio/mpegurl"
    "audio/mpg"
    "audio/musepack"
    "audio/ogg"
    "audio/opus"
    "audio/rn-mpeg"
    "audio/scpls"
    "audio/vnd.dolby.heaac.1"
    "audio/vnd.dolby.heaac.2"
    "audio/vnd.dts"
    "audio/vnd.dts.hd"
    "audio/vnd.rn-realaudio"
    "audio/vorbis"
    "audio/wav"
    "audio/webm"
    "audio/x-aac"
    "audio/x-adpcm"
    "audio/x-aiff"
    "audio/x-ape"
    "audio/x-m4a"
    "audio/x-matroska"
    "audio/x-mp1"
    "audio/x-mp2"
    "audio/x-mp3"
    "audio/x-mpegurl"
    "audio/x-mpg"
    "audio/x-ms-asf"
    "audio/x-ms-wma"
    "audio/x-musepack"
    "audio/x-pls"
    "audio/x-pn-au"
    "audio/x-pn-realaudio"
    "audio/x-pn-wav"
    "audio/x-pn-windows-pcm"
    "audio/x-realaudio"
    "audio/x-scpls"
    "audio/x-shorten"
    "audio/x-tta"
    "audio/x-vorbis"
    "audio/x-vorbis+ogg"
    "audio/x-wav"
    "audio/x-wavpack"
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/avi"
    "video/divx"
    "video/dv"
    "video/fli"
    "video/flv"
    "video/mkv"
    "video/mp2t"
    "video/mp4"
    "video/mp4v-es"
    "video/mpeg"
    "video/msvideo"
    "video/ogg"
    "video/quicktime"
    "video/vnd.divx"
    "video/vnd.mpegurl"
    "video/vnd.rn-realvideo"
    "video/webm"
    "video/x-avi"
    "video/x-flc"
    "video/x-flic"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-mpeg2"
    "video/x-mpeg3"
    "video/x-ms-afs"
    "video/x-ms-asf"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-ms-wvxvideo"
    "video/x-msvideo"
    "video/x-ogm"
    "video/x-ogm+ogg"
    "video/x-theora"
    "video/x-theora+ogg"
  ];
  archives = [
    "application/bzip2"
    "application/gzip"
    "application/vnd.android.package-archive"
    "application/vnd.ms-cab-compressed"
    "application/vnd.debian.binary-package"
    "application/x-7z-compressed"
    "application/x-7z-compressed-tar"
    "application/x-ace"
    "application/x-alz"
    "application/x-ar"
    "application/x-archive"
    "application/x-arj"
    "application/x-brotli"
    "application/x-bzip-brotli-tar"
    "application/x-bzip"
    "application/x-bzip-compressed-tar"
    "application/x-bzip1"
    "application/x-bzip1-compressed-tar"
    "application/x-cabinet"
    "application/x-cd-image"
    "application/x-compress"
    "application/x-compressed-tar"
    "application/x-cpio"
    "application/x-chrome-extension"
    "application/x-deb"
    "application/x-ear"
    "application/x-ms-dos-executable"
    "application/x-gtar"
    "application/x-gzip"
    "application/x-gzpostscript"
    "application/x-java-archive"
    "application/x-lha"
    "application/x-lhz"
    "application/x-lrzip"
    "application/x-lrzip-compressed-tar"
    "application/x-lz4"
    "application/x-lzip"
    "application/x-lzip-compressed-tar"
    "application/x-lzma"
    "application/x-lzma-compressed-tar"
    "application/x-lzop"
    "application/x-lz4-compressed-tar"
    "application/x-ms-wim"
    "application/x-rar"
    "application/x-rar-compressed"
    "application/x-rpm"
    "application/x-source-rpm"
    "application/x-rzip"
    "application/x-rzip-compressed-tar"
    "application/x-tar"
    "application/x-tarz"
    "application/x-tzo"
    "application/x-stuffit"
    "application/x-war"
    "application/x-xar"
    "application/x-xz"
    "application/x-xz-compressed-tar"
    "application/x-zip"
    "application/x-zip-compressed"
    "application/x-zstd-compressed-tar"
    "application/x-zoo"
    "application/zip"
    "application/zstd"
  ];
  code = [
    "text/english"
    "text/plain"
    "text/x-makefile"
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-csrc"
    "text/x-java"
    "text/x-moc"
    "text/x-pascal"
    "text/x-tcl"
    "text/x-tex"
    "application/x-shellscript"
    "text/x-c"
    "text/x-c++"
    "application/x-yaml"
    "application/x-json"
    "application/x-toml"
    "application/x-clj"
    "application/json"
  ];

  browser = [
    "google-chrome.desktop"
    "chromium.desktop"
    "firefox.desktop"
    "librewolf.desktop"
  ];
  editor = [
    "emacsclient.desktop"
    "emacs.desktop"
    "neovim.desktop"
    "vim.desktop"
    # "code.desktop"
  ];
  viewer =
    [
      "viewnior.desktop"
      "imv.desktop"
    ]
    ++ browser;
  player =
    [
      "vlc.desktop"
      "mpv.desktop"
    ]
    ++ browser;
  filemanager = [
    "thunar.desktop"
    "dolphin.desktop"
    "nautilus.desktop"
    "spacefm.desktop"
    "pcmanfm.desktop"
    "kitty-open.desktop"
    "emacs.desktop"
  ];
in {
  options.xdg = {
    # a la  https://www.pathname.com/fhs/pub/fhs-2.3.html#USRSRCSOURCECODE2
    userDirs.sourceCode = mkOption {
      type = with types; nullOr (coercedTo path toString str);
      default = "${config.home.homeDirectory}/src";
      defaultText =
        literalExpression ''"''${config.home.homeDirectory}/Code"'';
      description = "The source code directory.";
    };
  };

  config = {
    xdg.enable = true;
    xdg.userDirs = {
      enable = true;
      extraConfig = {
        "XDG_SOURCECODE_DIR" = config.xdg.userDirs.sourceCode;
      };
    };
    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        (genAttrs urls (_: browser))
        // (genAttrs code (_: editor))
        // (genAttrs images (_: viewer))
        // (genAttrs audioVideo (_: player))
        // {"inode/directory" = filemanager;}
        // {
          "x-scheme-handler/jetbrains" = "jetbrains-toolbox.desktop";
          "x-scheme-handler/slack" = "slack.desktop";
          "x-scheme-handler/obsidian" = "obsidian.desktop";
          "x-scheme-handler/terminal" = "kitty.desktop"; # https://github.com/chmln/handlr#setting-default-terminal
        };
      associations.removed = {
        "inode/directory" = ["code.desktop"];
      };
    };

    xdg.dataFile = lib.my.files.sourceSet {
      dir = ../../local/share/icons/hicolor;
      base = ../../local/share;
    };
  };
}
