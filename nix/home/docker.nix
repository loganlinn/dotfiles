{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.docker.credHelpers;
  configFile = "${config.home.homeDirectory}/.docker/config.json";

  # Merge rather than replace: docker writes its own state (currentContext,
  # plugins) into the same file, so it cannot be a read-only store symlink.
  mergeCredHelpers = pkgs.writeShellScript "docker-merge-cred-helpers" ''
    set -euo pipefail
    config=$1
    helpers=$2
    mkdir -p "$(dirname "$config")"
    [ -s "$config" ] || printf '{}\n' >"$config"
    tmp=$(mktemp)
    ${lib.getExe pkgs.jq} --argjson helpers "$helpers" \
      '.credHelpers = ((.credHelpers // {}) + $helpers)' "$config" >"$tmp"
    mv "$tmp" "$config"
  '';
in {
  options.my.docker.credHelpers = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    example = lib.literalExpression ''{"public.ecr.aws" = "ecr-login";}'';
    description = ''
      Registry hostname -> `docker-credential-<name>` helper, merged into
      ~/.docker/config.json.

      Per-registry helpers take precedence over the credential store that the
      docker CLI auto-detects. On darwin that store is `osxkeychain` whenever
      the binary is on PATH (OrbStack ships one), which fails with
      `Keychain Error. (-61)` from any session without an Aqua security
      session -- notably over SSH, where Security falls back to the system
      domain and the write needs root.
    '';
  };

  config = {
    home.shellAliases = {
      dk = "docker";
    };

    home.packages =
      lib.optional
      (lib.any (helper: helper == "ecr-login") (lib.attrValues cfg))
      pkgs.amazon-ecr-credential-helper;

    home.activation.dockerCredHelpers = lib.mkIf (cfg != {}) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${mergeCredHelpers} ${lib.escapeShellArg configFile} ${
          lib.escapeShellArg (builtins.toJSON cfg)
        }
      ''
    );
  };
}
