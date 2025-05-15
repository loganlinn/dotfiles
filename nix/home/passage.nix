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
    age.package = mkOption {
      type = types.package;
      default = if config.programs.age-op.enable then config.programs.age-op.package else pkgs.age;
    };
    settings = {
      storeDirectory = mkOptionalPathOption { };
      identitiesFile = mkOptionalPathOption { };
      recipientsFile = mkOptionalPathOption { };
      recipients = mkOptionalPathOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = {
    home.packages = [
      cfg.package
      cfg.age.package
    ];
    home.sessionVariables = filterAttrs (n: v: v != null && v != "") {
      PASSAGE_DIR = cfg.settings.storeDirectory;
      PASSAGE_IDENTITIES_FILE = cfg.settings.identitiesFile;
      PASSAGE_AGE = "${getExe cfg.age.package}";
      PASSAGE_RECIPIENTS_FILE = cfg.settings.recipientsFile;
      PASSAGE_RECIPIENTS = concatStringsSep "," cfg.settings.recipients;
    };
  };
}
