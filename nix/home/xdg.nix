{
  config,
  lib,
  ...
}:
with lib; {
  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = mkMerge [
      (
        listToAttrs
        (forEach [
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
          ] (mimeType: {
            name = mimeType;
            value = ["google-chrome.desktop"];
          }))
      )
      {
        "inode/directory" = [
          "dolphin.desktop"
          "nautilus.desktop"
          "thunar.desktop"
          "spacefm.desktop"
          "pcmanfm.desktop"
          "kitty-open.desktp"
          "emacs.desktop"
          "code.desktop"
        ];
        "x-scheme-handler/jetbrains" = "jetbrains-toolbox.desktop";
        "x-scheme-handler/slack" = "slack.desktop";
      }
    ];
    associations.added = {
      "application/x-shellscript" = ["emacs.desktop"];
      "video/webm" = ["firefox.desktop"];
    };
  };
}
