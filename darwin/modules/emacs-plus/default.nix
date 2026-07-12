{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.emacs-plus;
  caskType = with types; either str (attrsOf anything); # options.homebrew.casks.type.nestedTypes.elemType;
in {
  options = {
    programs.emacs-plus = {
      enable = mkEnableOption "emacs-plus";
      cask = mkOption {
        type = caskType;
        default = "d12frosted/emacs-plus/emacs-plus-app";
        example = literalExpression ''
          {
            name = "d12frosted/emacs-plus/emacs-plus@31";
            args = ["with-native-comp" "with-xwidgets" "with-c9rgreen-sonoma-icon"];
          }
        '';
        description = "Cask to install from d12frosted/emacs-plus tap";
      };
    };
  };

  config = mkIf cfg.enable {
    homebrew.enable = true;
    # Declare the tap with trusted = true so nix-darwin activation runs
    # `brew trust --tap` on it before `brew bundle`. Recent Homebrew enables
    # HOMEBREW_REQUIRE_TAP_TRUST, which refuses casks from untrusted non-official
    # taps; nix-darwin's homebrew.taps.*.trusted defaults to false, so the bare
    # string form (or relying on auto-tap from the cask name) leaves it untrusted.
    homebrew.taps = [
      {
        name = "d12frosted/emacs-plus";
        trusted = true;
      }
    ];
    homebrew.casks = [cfg.cask];
    homebrew.brews = [
      # native compilation (emacs-plus --with-native-comp)
      "gcc"
      "libgccjit"
      # core utilities doom shells out to
      "coreutils"
      # :term vterm (compiles the vterm module against system libvterm)
      "cmake"
      "libtool"
      "libvterm"
      # :lang org
      "pngpaste"
    ];
    environment.systemPackages = with pkgs; [
      fd
      git
      hunspell
      ripgrep
      (writeShellScriptBin "magit" (readFile ../../../bin/magit))
    ];
  };
}
