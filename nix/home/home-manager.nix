{ config, lib, ... }:

with lib;
let
  flakeDirectory = "${config.home.homeDirectory}/.dotfiles";
  hmConfigDir = "${config.xdg.configHome}/home-manager";
in
{
  # Create symlink at ~/.config/home-manager to this flake, allowing home-manager(1) to work without additional arguments
  home.activation.linkHomeManagerFlake = hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -d ${hmConfigDir} ]] && [[ -d ${flakeDirectory} ]]; then
      $DRY_RUN_CMD ln $VERBOSE_ARG -s "${flakeDirectory}" "${hmConfigDir}"
    fi
  '';
}
