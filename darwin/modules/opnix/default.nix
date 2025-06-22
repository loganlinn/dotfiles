{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.onepassword-secrets;

  # Create a new pkgs instance with our overlay
  pkgsWithOverlay = import pkgs.path {
    inherit (pkgs) system;
    overlays = [ inputs.opnix.overlays.default ];
  };

  # Create a system group for opnix token access
  opnixGroup = "onepassword-secrets";
in
{
  options.services.onepassword-secrets = {
    enable = lib.mkEnableOption "1Password secrets integration";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgsWithOverlay.opnix;
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = "/etc/opnix-token";
      description = ''
        Path to file containing the 1Password service account token.
        The file should contain only the token and should have appropriate permissions (640).
        Will be readable by members of the ${opnixGroup} group.

        You can set up the token using the opnix CLI:
          opnix token set
          # or with a custom path:
          opnix token set -path /path/to/token
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to secrets configuration file";
    };

    outputDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/opnix/secrets";
      description = "Directory to store retrieved secrets";
    };

    # New option for users that should have access to the token
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users that should have access to the 1Password token through group membership";
      example = [
        "alice"
        "bob"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the opnix group
    users.groups.${opnixGroup} = {
      gid = 20000; # Use a high GID to avoid conflicts on macOS
      description = "1Password secrets access group";
      members = cfg.users;
    };

    environment.systemPackages = [ cfg.package ];

    system.activationScripts.postActivation.text = ''
      echo "Setting up 1Password secrets..." >&2

      # Ensure output directory exists with correct permissions
      mkdir -p ${cfg.outputDir}
      chmod 750 ${cfg.outputDir}

      # Set up token file with correct group permissions if it exists
      if [ -f ${cfg.tokenFile} ]; then
        # Ensure token file has correct ownership and permissions
        chown root:${opnixGroup} ${cfg.tokenFile}
        chmod 640 ${cfg.tokenFile}
      fi

      # Validate token file existence and permissions
      if [ ! -f ${cfg.tokenFile} ]; then
        echo "Error: Token file ${cfg.tokenFile} does not exist!" >&2
        echo "Please create it first using: opnix token set -path ${cfg.tokenFile}" >&2
        exit 1
      fi

      if [ ! -r ${cfg.tokenFile} ]; then
        echo "Error: Token file ${cfg.tokenFile} is not readable!" >&2
        echo "You may need to add your user to the ${opnixGroup} group" >&2
        exit 1
      fi

      # Validate token is not empty
      if [ ! -s ${cfg.tokenFile} ]; then
        echo "Error: Token file is empty!" >&2
        exit 1
      fi

      # Run the secrets retrieval tool
      ${cfg.package}/bin/opnix secret \
        -token-file ${cfg.tokenFile} \
        -config ${cfg.configFile} \
        -output ${cfg.outputDir} || {
        echo "Error: Failed to retrieve secrets" >&2
        exit 1
      }

      echo "1Password secrets setup completed successfully" >&2
    '';

    launchd.daemons.onepassword-secrets-refresh = {
      serviceConfig = {
        ProgramArguments = [
          "${cfg.package}/bin/opnix"
          "secret"
          "-token-file"
          (toString cfg.tokenFile)
          "-config"
          (toString cfg.configFile)
          "-output"
          (toString cfg.outputDir)
        ];
        StartInterval = 3600;
        RunAtLoad = true;
        EnvironmentVariables = {
          PATH = "${cfg.package}/bin:${config.environment.systemPath}";
        };
        UserName = "root";
        GroupName = opnixGroup;
        StandardOutPath = "/var/log/onepassword-secrets.log";
        StandardErrorPath = "/var/log/onepassword-secrets.error.log";
      };
    };
  };
}
