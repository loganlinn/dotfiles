{ config, pkgs, lib, ... }:

with lib;
let
  flakeDirectory = "${config.home.homeDirectory}/.dotfiles";
  hmConfigDir = "${config.xdg.configHome}/home-manager";
in {
  # Create symlink at ~/.config/home-manager to this flake, allowing home-manager(1) to work without additional arguments
  home.activation.linkHomeManagerFlake =
    hm.dag.entryAfter [ "writeBoundary" ] ''
      if [[ ! -d ${hmConfigDir} ]] && [[ -d ${flakeDirectory} ]]; then
        $DRY_RUN_CMD ln $VERBOSE_ARG -s "${flakeDirectory}" "${hmConfigDir}"
      fi
    '';

} // lib.mkIf pkgs.stdenv.isLinux {
  # desktop notifications for home-manager activation DAG
  home.extraActivationPath = [ pkgs.libnotify ];

  # TODO maybe can just use all entries from config.home.activation for entryBefore/entryAfter
  home.activation.notifyActivationPre = hm.dag.entryBefore ["checkLinkTargets"] ''
    declare -gr _notifyActivationId=$(
      notify-send \
        -u low \
        -a home-manager \
        -p \
        "home-manager activation starting" \
        "Generation: #$oldGenNum -> #$newGenNum"
    )
  '';

  home.activation.notifyActivationPost = hm.dag.entryAfter [ "reloadSystemd" "onFilesChange" ] ''
    notify-send \
      -u low \
      -r "$_notifyActivationId" \
      -a home-manager \
      "home-manager activation finished" \
      "Generation: #$oldGenNum -> #$newGenNum"
  '';
}
