{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.brewAutoupdate;

  effectiveLeavesOnly = if cfg.leavesOnly != null then cfg.leavesOnly else cfg.only == null;

  startArgs = concatStringsSep " " (
    [
      (toString cfg.interval)
      "--upgrade"
    ]
    ++ optional cfg.cleanup "--cleanup"
    ++ optional cfg.immediate "--immediate"
    ++ optional cfg.sudo "--sudo"
    ++ optional effectiveLeavesOnly "--leaves-only"
    ++ optional (cfg.only != null && cfg.only != [ ]) ("--only " + concatStringsSep "," cfg.only)
    ++ optional cfg.acOnly "--ac-only"
  );

  brew = "${config.homebrew.prefix}/bin/brew";
  user = config.my.user.name;
  stateFile = "/var/db/brew-autoupdate/config-args";
in
{
  options.services.brewAutoupdate = {
    enable = mkEnableOption "brew autoupdate (DomT4/homebrew-autoupdate)";

    interval = mkOption {
      type = types.ints.positive;
      default = 86400;
      description = "Update interval in seconds (default: 86400 = 24 hours).";
    };

    cleanup = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically clean Homebrew's cache and logs after upgrading.";
    };

    immediate = mkOption {
      type = types.bool;
      default = false;
      description = "Start autoupdate immediately on activation rather than waiting for the first interval.";
    };

    sudo = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open a GUI prompt for casks requiring sudo.
        Automatically installs the pinentry-mac formula when enabled.
      '';
    };

    leavesOnly = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Only upgrade formulae not depended on by other installed formulae.
        Defaults to true when `only` is not set, false otherwise.
        Mutually exclusive with `only`.
      '';
    };

    only = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = ''
        Only upgrade the specified formulae and/or casks (comma-separated to brew).
        Mutually exclusive with `leavesOnly`.
      '';
    };

    acOnly = mkOption {
      type = types.bool;
      default = true;
      description = "Only run autoupdate when on AC power.";
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = !(effectiveLeavesOnly && cfg.only != null);
          message = "services.brewAutoupdate: leavesOnly and only are mutually exclusive";
        }
      ];

      system.activationScripts.postActivation.text =
        if cfg.enable then
          ''
            # brew-autoupdate: enable/reconfigure
            if [[ -x "${brew}" ]]; then
              _bau_desired='${startArgs}'
              _bau_current=""
              if [[ -f "${stateFile}" ]]; then
                _bau_current=$(<"${stateFile}")
              fi
              if [[ "$_bau_desired" != "$_bau_current" ]]; then
                echo >&2 "brew-autoupdate: (re)configuring service..."
                sudo -Hu ${escapeShellArg user} "${brew}" autoupdate delete 2>/dev/null || true
                # shellcheck disable=SC2086
                sudo -Hu ${escapeShellArg user} "${brew}" autoupdate start $_bau_desired
                mkdir -p "$(dirname "${stateFile}")"
                printf '%s' "$_bau_desired" > "${stateFile}"
              else
                echo >&2 "brew-autoupdate: configuration unchanged"
              fi
            else
              echo >&2 "brew-autoupdate: brew not found at ${brew}, skipping"
            fi
          ''
        else
          ''
            # brew-autoupdate: disable
            if [[ -f "${stateFile}" ]]; then
              echo >&2 "brew-autoupdate: disabling service..."
              if [[ -x "${brew}" ]]; then
                sudo -Hu ${escapeShellArg user} "${brew}" autoupdate delete 2>/dev/null || true
              fi
              rm -f "${stateFile}"
            fi
          '';
    }

    (mkIf cfg.enable {
      homebrew.enable = true;
      homebrew.taps = [ "DomT4/homebrew-autoupdate" ];
      homebrew.brews = mkIf cfg.sudo [ "pinentry-mac" ];

      # Disable Homebrew's built-in auto-update to avoid duplicate work
      environment.variables.HOMEBREW_NO_AUTO_UPDATE = mkDefault "1";
    })
  ];
}
