{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.emacs-plus;
in
{
  options = {
    programs.emacs-plus = {
      enable = (mkEnableOption "emacs-plus") // {
        default = true;
      };
      version = mkOption {
        type = types.str;
        default = "31";
      };
    };

  };

  config = mkIf cfg.enable {
    homebrew.enable = true;
    homebrew.taps = [ { name = "d12frosted/emacs-plus"; } ];
    homebrew.brews = [
      "gcc"
      "coreutils"
      "cmake" # :term vterm
      "libtool" # :term vtern
      "pngpaste" # :lang org
      {
        name = "emacs-plus@${cfg.version}";
        args = [
          "with-c9rgreen-sonoma-icon"
          # "with-imagemagick"
          "with-native-comp" # build with native compilation aka gccemacs
          # "with-debug"     # build with debug symbols and debugger friendly optimizations
          # "with-poll"      # build with poll() instead of select() to enable more file descriptors
          "with-xwidgets" # build with native macos webkit support
          # "with-no-frame-refocus" # disables frame re-focus (ie. closing one frame does not refocus another one)
        ];
      }
    ];

    environment.systemPackages = with pkgs; [
      git
      ripgrep
      fd
    ];
  };
}
