{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  settingsType = types.submodule {
    freeformType = with types;
      attrsOf (attrsOf (oneOf str bool int path (listOf str)));
    options = {
      # TODO: spec some options (see AVAILABLE CONFIGURATION OPTIONS)
    };
    config = {};
  };

  mkDavfs2Conf = let
    mkQuoted = s: ''"${escape [''"'' "’"] s}"'';
    mkValue =
      if isBool value
      then
        (
          if value
          then 1
          else 0
        )
      else if isString value
      then mkQuoted value
      else toString value;
  in
    lib.generators.toINI {
      mkSectionName = mkQuoted;
      mkKeyValue = key: value: "${key}=${mkValue value}";
    };

  cfg = config.my.davfs2;
in {
  options.my.davfs2 = {
    secrets.source = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
    davs = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            enable = mkEnableOption "";
            url = mkOption {type = str;};
            settings = mkOption {
              type = settingsType;
              default = {};
            };
            mountPoint = mkOption {
              type = str;
              default = "";
            };
            mountOptions = mkOption {
              type = listOf str;
              default = ["_netdev" "noauto"];
            };
          };
        });
      default = {};
    };
  };

  config = lib.mkIf config.services.davfs2.enable {
    fileSystems =
      mapAttrs'
      (name: value: {
        name =
          if value.mountPoint != ""
          then value.mountPoint
          else "/mnt/dav/${name}";
        value = {
          fsType = "davfs";
          device = value.url;
          noCheck = true;
          options =
            (optional (value.settings != {})
              "conf=${pkgs.writeText "davfs2.conf" (mkDavfs2Conf value.settings)}")
            ++ value.mountOptions;
        };
      })
      cfg.davs;

    environment.etc."davfs2/secrets" = mkIf (cfg.secrets.source != null) {
      source = cfg.secrets.source;
      mode = 600;
    };

    # system.activationScripts.davfs2-secrets = ''
    # '';
  };
}
