{
  homebrew.enable = true;
  homebrew.taps = [ { name = "d12frosted/emacs-plus"; } ];
  homebrew.brews = [
    {
      name = "emacs-plus@31";
      args = [
        "verbose"
        "with-c9rgreen-sonoma-icon"
        # "with-imagemagick"
        "with-native-comp" # build with native compilation aka gccemacs
        # "with-debug"     # build with debug symbols and debugger friendly optimizations
        # "with-poll"      # build with poll() instead of select() to enable more file descriptors
        # "with-xwidgets"  # build with native macos webkit support
        # "with-no-frame-refocus" # disables frame re-focus (ie. closing one frame does not refocus another one)
      ];
    }
  ];
}
