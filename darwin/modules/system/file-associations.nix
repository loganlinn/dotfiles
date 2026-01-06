{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.system.duti;
in {
  options.system.duti = {
    enable = mkEnableOption "duti file associations manager";

    settings = mkOption {
      type = types.lines;
      default = "";
      description = ''
        File association settings in duti format.
        Each line should be in the format: bundle-id <uti|scheme|extension|mime> [role]

        Can be specified as a list of strings or a multiline string.
      '';
      example = literalExpression ''
        '''
          org.videolan.vlc .mkv all
          org.videolan.vlc .mp4 all
          com.apple.Safari public.html all
          org.mozilla.Firefox ftp
        '''
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Install duti package
    {
      environment.systemPackages = [pkgs.duti];
    }

    # Generate settings file and apply on activation
    (mkIf (cfg.settings != "") {
      environment.etc."duti/settings.duti".text = cfg.settings;

      system.activationScripts.postUserActivation.text = ''
        echo "Setting file associations with duti..."
        ${pkgs.duti}/bin/duti /etc/duti/settings.duti
      '';
    })
  ]);
}
