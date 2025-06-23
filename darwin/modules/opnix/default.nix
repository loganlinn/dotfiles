{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    mkOption
    concatStringsSep
    escapeShellArg
    getExe'
    ;
  chown = getExe' pkgs.coreutils "chown";
  mkdir = getExe' pkgs.coreutils "mkdir";
  chmod = getExe' pkgs.coreutils "mkdir";

  cfg = config.services.onepassword-secrets;

  # Create a new pkgs instance with our overlay
  pkgsWithOverlay = import pkgs.path {
    inherit (pkgs) system;
    overlays = [ inputs.opnix.overlays.default ];
  };

  userName = "_opnix";
  groupName = "_opnix";
in
{
  options.services.onepassword-secrets = {
    enable = mkEnableOption "1Password secrets integration";

    package = mkOption {
      type = lib.types.package;
      default = pkgsWithOverlay.opnix;
    };

    tokenFile = mkOption {
      type = lib.types.path;
      default = "/etc/opnix-token";
      description = ''
        Path to file containing the 1Password service account token.
        The file should be owned by ${userName}:${groupName} and contain only the token and should have appropriate permissions (640).

        You can set up the token using the 'opnix' CLI:
          opnix token set
          # or with a custom path:
          opnix token set -path /path/to/token
      '';
    };

    configFile = mkOption {
      type = lib.types.path;
      description = "Path to secrets configuration file";
    };

    outputDir = mkOption {
      type = lib.types.str;
      default = "/run/opnix/secrets";
      description = "Directory to store retrieved secrets";
    };

    # New option for users that should have access to the token
    users = mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users that should have access to the 1Password token through group membership";
      example = [
        "alice"
        "bob"
      ];
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.${userName} = {
        createHome = false;
        description = "opnix service user";
        gid = config.users.groups.${groupName}.gid;
        home = "/var/lib/opnix";
        shell = "/bin/bash";
        uid = mkDefault 544;
      };
      groups.${groupName} = {
        gid = mkDefault 544;
        description = "opnix service user group";
        members = cfg.users;
      };
      knownUsers = [ userName ];
      knownGroups = [ groupName ];
    };

    environment.systemPackages = [ cfg.package ];

    launchd.daemons.onepassword-secrets-refresh = {
      serviceConfig = {
        UserName = userName;
        GroupName = groupName;
        EnvironmentVariables.PATH = "${cfg.package}/bin:${config.environment.systemPath}";
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
        ProcessType = "Interactive";
        StartInterval = 3600;
        RunAtLoad = true;
        StandardOutPath = "/var/log/opnix-stdout.log";
        StandardErrorPath = "/var/log/opnix-stderr.log";
        WatchPaths = [
          (toString cfg.tokenFile)
          (toString cfg.configFile)
        ];
        WorkingDirectory = toString cfg.outputDir;
      };
    };

    system.activationScripts.postActivation = {
      text = ''
        echo >&2 "Activating opnix secrets"
        mkdir -p ${escapeShellArg cfg.outputDir}
        chown 750 ${escapeShellArg cfg.outputDir}
        chown ${userName}:${groupName} ${escapeShellArg cfg.tokenFile}
        chmod 640 ${escapeShellArg cfg.tokenFile}
        ${concatStringsSep " " (
          map escapeShellArg config.launchd.daemons.onepassword-secrets-refresh.serviceConfig.ProgramArguments
        )}
      '';
    };
  };
}
