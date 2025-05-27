{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.kanata;
in
{
  options.services.kanata = {
    enable = mkEnableOption "kanata";
    configFiles = mkOption {
      type = with types; (listOf (coercedTo path toString str));
      default = [ ];
    };
    port = mkOption {
      type = types.nullOr types.port;
      default = null;
    };
    debug = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    homebrew.brews = [
      { name = "kanata"; }
    ];

    # https://www.reddit.com/r/ErgoMechKeyboards/comments/1fojvif/comment/mg54mz1/
    environment.launchDaemons."com.loganlinn.kanata" = {
      enable = false;
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.loganlinn.kanata</string>

            <key>ProgramArguments</key>
            <array>
                <string>${config.homebrew.brewPrefix}/kanata</string>
                ${concatLines (
                  map f ''
                    <string>--cfg</string>
                    <string>${f}</string>
                  '' cfg.configFiles
                )}
                ${optionalString cfg.port ''
                  <string>--port</string>
                  <string>${toString cfg.port}</string>
                ''}
                ${optionalString cfg.debug ''
                  <string>--debug</string>
                ''}
            </array>

            <key>RunAtLoad</key>
            <true/>

            <key>KeepAlive</key>
            <true/>

            <key>StandardOutPath</key>
            <string>/Library/Logs/Kanata/kanata.out.log</string>

            <key>StandardErrorPath</key>
            <string>/Library/Logs/Kanata/kanata.err.log</string>
        </dict>
        </plist>
      '';
    };
  };
}
