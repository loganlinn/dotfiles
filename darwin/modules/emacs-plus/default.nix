{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.emacs-plus;
  emacs-plus-brew = {
        name = "emacs-plus@${cfg.version}";
        args = [
          # "with-imagemagick"
          # "with-debug"     # build with debug symbols and debugger friendly optimizations
          "with-xwidgets" #
          # "with-no-frame-refocus" # disables frame re-focus (ie. closing one frame does not refocus another one)
        ]
        ++ optional ((toString cfg.icon) != "") "with-${cfg.icon}-icon"
        ++ optional cfg.enableNativeComp "with-native-comp"
        ++ optional cfg.enableXwidgets "with-xwidgets"
        ++ optional cfg.enablePoll "with-poll";
      };
in
{
  options = {
    programs.emacs-plus = {
      enable = mkEnableOption "emacs-plus";
      version = mkOption {
        type = types.str;
        default = "31";
      };
      icon = mkOption {
        type = types.str;
        default = "c9rgreen-sonoma";
      };
      enableNativeComp = mkEnableOption "Build with native compilation aka gccemacs";
      enableXwidgets = mkEnableOption "Build with native macos webkit support";
      enablePoll = mkEnableOption "Build with poll() instead of select() to enable more file descriptors";
    };
  };

  config = mkIf cfg.enable {
    programs.emacs-plus = {
      enableNativeComp = mkDefault true;
      enableXwidgets = mkDefault true;
    };

    homebrew.enable = true;
    homebrew.taps = [ { name = "d12frosted/emacs-plus"; } ];
    homebrew.brews = [
      "gcc"
      "coreutils"
      "cmake" # :term vterm
      "libtool" # :term vtern
      "pngpaste" # :lang org
      emacs-plus-brew
    ];

    environment.systemPackages = with pkgs; [
      git
      ripgrep
      fd
    ];
  };
}
