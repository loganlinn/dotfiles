{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  options = {
    quick-actions.dequarantine.enable = mkEnableOption "dequarantine";
  };

  config = {
    system.activationScripts.quick-actions.text = ''
      # install .workflow files to ~/Library/Services
    '';
  };
}
