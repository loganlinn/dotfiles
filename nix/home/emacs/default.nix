{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  imports = [ ../doom ];

  programs.emacs = {
    enable = mkDefault true;
    # NOTE: emacs-overlay provides the following attributes:
    #     - emacs-unstable         (latest tag)
    #     - emacs-unstable-nox     (latest tag, without X dependencies)
    #     - emacs-unstable-pgtk    (latest tag, with native wayland support)
    #     - emacs-git              (master branch)
    #     - emacs-git-nox          (master branch, without X dependencies)
    #     - emacs-pgtk             (master branch, with native wayland support)
    # See: https://github.com/nix-community/emacs-overlay?tab=readme-ov-file#emacs-overlay
    #
    # TODO detect if using wayland and use pkgs.emacs-pgtk instead.
    #      a new option is needed to indicate wayland b/c there isn't a reliable way to check afaict.
    #
    # The `emacs-*` attributes are provided by emacs-overlay.
    # > `emacs-git` is built from the latest master branch and emacs-unstable is built from the latest tag.
    #
    #
    package = mkDefault pkgs.emacs-unstable; # most recent git tag
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  services.emacs = {
    package = mkDefault config.programs.emacs.package;
    client = {
      enable = mkDefault true;
      arguments = [ "-c" ];
    };
  };

  programs.zsh.initExtra = ''
    function e() {
        hash emacs || return 1
        command emacs "$@" &
        disown %+;
    }

    function ec() {
        hash emacsclient || return 1
        command emacsclient --alternate-editor="" --create-frame "$@" &
        disown %+;
    }

    function et() {
      emacs -nw "$@"
    }
  '';
}
