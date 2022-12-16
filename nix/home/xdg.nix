{ ... }:

{
  xdg.userDirs.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["google-chrome.desktop"];
      "x-scheme-handler/http" = ["google-chrome.desktop"];
      "x-scheme-handler/https" = ["google-chrome.desktop"];
      "x-scheme-handler/about" = ["google-chrome.desktop"];
      "x-scheme-handler/unknown" = ["google-chrome.desktop"];
      "x-scheme-handler/mailto" = ["google-chrome.desktop"];
      "x-scheme-handler/webcal" = ["google-chrome.desktop"];
      "x-scheme-handler/jetbrains" = ["jetbrains-toolbox.desktop"];
    };
    associations.added = {
      "application/x-shellscript" = ["emacs.desktop"];
      "video/webm" = ["firefox.desktop"];
    };
  };
  xdg.desktopEntries = {
    # TODO Chromium profiles
  };
}
