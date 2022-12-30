{ ... }:

{
  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    # onActivation = {
    #   autoUpdate = false;
    #   # upgrade = true; # TRYME
    # };
    taps = [
      # "d12frosted/emacs-plus"
      # "railwaycat/emacsport"
      "Azure/kubelogin"
    ];
    brews = [
      "kubelogin"
      # "azure-cli"
      # "libvterm"
      # {
      #  name = "emacs-plus@28";
      #  args = [
      #    "with-no-titlebar"
      #    "with-xwidgets"
      #    "with-native-comp"
      #    "with-modern-doom3-icon"
      #  ];
      # }
    ];
    casks = [
      "1password"
      # "google-chrome"
      "kitty"
      "slack"
    ];
  };
}
