{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  mkOptionalPathOption =
    attrs:
    mkOption {
      type = with types; nullOr (coercedTo path toString str);
      default = null;
    }
    // attrs;
  cfg = config.programs.passage;
in
{
  imports = [
    ./age-op.nix
  ];

  options.programs.passage = {
    enable = mkEnableOption "passage";
    package = mkPackageOption pkgs "passage" { };
    settings = {
      storeDirectory = mkOptionalPathOption { };
      identitiesFile = mkOptionalPathOption { };
      ageExe = mkOptionalPathOption {
        default =
          if config.programs.age-op.enable then "${config.programs.age-op.package}/bin/age-op" else null;
      };
      recipientsFile = mkOptionalPathOption { };
      recipients = mkOptionalPathOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = {
    home.packages = [ cfg.package ];
    home.sessionVariables = filterAttrs (n: v: v != null) {
      PASSAGE_DIR = cfg.storeDirectory;
      PASSAGE_IDENTITIES_FILE = cfg.identitiesFile;
      PASSAGE_AGE = cfg.ageExe;
      PASSAGE_RECIPIENTS_FILE = cfg.recipientsFile;
      PASSAGE_RECIPIENTS = concatStringsSep "," cfg.recipients;
    };
  };
}
