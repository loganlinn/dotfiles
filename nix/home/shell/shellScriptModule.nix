{ writeShellApplication, lib }:

with lib;

types.submodule (
  { config, name, ... }:
  {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the script to write.";
        default = name;
      };

      text = mkOption {
        type = types.str;
        description = "The shell script's text, not including a shebang.";
      };

      runtimeInputs = mkOption {
        type = types.listOf (types.either types.str types.package);
        description = "Inputs to add to the shell script's `$PATH` at runtime.";
        default = [ ];
      };

      runtimeEnv = mkOption {
        type = types.nullOr (types.attrsOf types.anything);
        description = "Extra environment variables to set at runtime.";
        default = null;
      };

      meta = mkOption {
        type = types.attrsOf types.anything;
        description = "`stdenv.mkDerivation`'s `meta` argument.";
        default = { };
      };

      # TODO uncomment once nixpkgs upgraded to include https://github.com/NixOS/nixpkgs/commit/d04d2858c928ae57bec19d32b43ab5e3c91b9823
      # passthru = mkOption {
      #   type = types.attrsOf types.anything;
      #   description = "`stdenv.mkDerivation`'s `passthru` argument.";
      #   default = { };
      # };

      checkPhase = mkOption {
        type = types.nullOr types.str;
        description = "The `checkPhase` to run. Defaults to `shellcheck` on supported platforms and `bash -n`. The script path will be given as `$target` in the `checkPhase`.";
        default = null;
      };

      excludeShellChecks = mkOption {
        type = types.listOf types.str;
        description = "Checks to exclude when running `shellcheck`, e.g. `[ \"SC2016\" ]`. See <https://www.shellcheck.net/wiki/> for a list of checks.";
        default = [ ];
      };

      extraShellCheckFlags = mkOption {
        type = types.listOf types.str;
        description = "Extra command-line flags to pass to ShellCheck.";
        default = [ ];
      };

      bashOptions = mkOption {
        type = types.listOf types.str;
        description = "Bash options to activate with `set -o` at the start of the script. Defaults to `[ \"errexit\" \"nounset\" \"pipefail\" ]`.";
        default = [
          "errexit"
          "nounset"
          "pipefail"
        ];
      };

      derivationArgs = mkOption {
        type = types.attrsOf types.anything;
        description = ''
          Extra arguments to pass to `stdenv.mkDerivation`.

          :::{.caution}
          Certain derivation attributes are used internally,
          overriding those could cause problems.
          :::
        '';
        default = { };
      };

      package = mkOption {
        type = types.package;
        readOnly = true;
        internal = true;
      };
    };
    config = {
      package = writeShellApplication {
        inherit (config)
          name
          text
          runtimeInputs
          runtimeEnv
          meta
          # passthru
          checkPhase
          excludeShellChecks
          extraShellCheckFlags
          bashOptions
          derivationArgs
          ;
      };
    };
  }
)
