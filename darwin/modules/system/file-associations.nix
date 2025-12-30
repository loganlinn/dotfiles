{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.system.duti;

  settingType = types.submodule {
    options = {
      bundleId = mkOption {
        type = types.str;
        description = "Bundle identifier of the application (e.g., com.apple.Safari)";
        example = "org.videolan.vlc";
      };

      uti = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Uniform Type Identifier, file extension, or MIME type.
          Extensions should start with a dot (e.g., .mp4) or have no dots.
          MIME types should contain a slash (e.g., video/mp4).
          Cannot be used with scheme.
        '';
        example = "public.html";
      };

      role = mkOption {
        type = types.enum ["all" "viewer" "editor" "shell" "none"];
        default = "all";
        description = ''
          Role the application should handle for the given UTI:
          - all: application handles all roles
          - viewer: application handles reading and displaying documents
          - editor: application can manipulate and save (implies viewer)
          - shell: application can execute the item
          - none: application cannot open but provides an icon
        '';
      };

      scheme = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          URL scheme (e.g., ftp, http, mailto).
          Cannot be used with uti or role.
        '';
        example = "ftp";
      };
    };
  };

  # Generate a single line for the .duti file
  settingToLine = setting:
    if setting.scheme != null
    then "${setting.bundleId}    ${setting.scheme}"
    else "${setting.bundleId}    ${setting.uti}    ${setting.role}";

  # Generate the full .duti file content
  dutiFileContent = concatMapStringsSep "\n" settingToLine cfg.settings;
in {
  options.system.duti = {
    enable = mkEnableOption "duti file associations manager";

    settings = mkOption {
      type = types.listOf settingType;
      default = [];
      description = "List of file association settings.";
      example = literalExpression ''
        [
          {
            bundleId = "org.videolan.vlc";
            uti = ".mkv";
            role = "all";
          }
          {
            bundleId = "com.apple.Safari";
            uti = "public.html";
            role = "all";
          }
          {
            bundleId = "org.mozilla.Firefox";
            scheme = "ftp";
          }
        ]
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Validation: ensure uti and scheme are not both set
    {
      assertions =
        map (setting: {
          assertion = !(setting.uti != null && setting.scheme != null);
          message = "duti setting cannot have both 'uti' and 'scheme' set: ${setting.bundleId}";
        })
        cfg.settings;
    }

    # Validation: ensure at least one of uti or scheme is set
    {
      assertions =
        map (setting: {
          assertion = setting.uti != null || setting.scheme != null;
          message = "duti setting must have either 'uti' or 'scheme' set: ${setting.bundleId}";
        })
        cfg.settings;
    }

    # Validation: role is only valid with uti
    {
      assertions =
        map (setting: {
          assertion = !(setting.scheme != null && setting.role != "all");
          message = "duti setting cannot have 'role' when using 'scheme': ${setting.bundleId}";
        })
        cfg.settings;
    }

    # Install duti package
    {
      environment.systemPackages = [pkgs.duti];
    }

    # Generate settings file and apply on activation
    (mkIf (cfg.settings != []) {
      environment.etc."duti/settings.duti".text = dutiFileContent;

      system.activationScripts.postUserActivation.text = ''
        echo "Setting file associations with duti..."
        ${pkgs.duti}/bin/duti /etc/duti/settings.duti
      '';
    })
  ]);
}
