{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.src-get;

  parseRepoRef = ref: let
    parts = splitString "/" ref;
    n = builtins.length parts;
  in
    if n == 2
    then {
      url = "https://${cfg.defaultHost}/${ref}";
      dir = "${cfg.home}/${cfg.defaultHost}/${ref}";
    }
    else if n == 3
    then {
      url = "https://${ref}";
      dir = "${cfg.home}/${ref}";
    }
    else throw "my.src-get.repos: invalid key '${ref}', expected 'owner/repo' or 'host/owner/repo'";

  resolveRepo = name: repoCfg: let
    parsed = parseRepoRef name;
  in {
    url =
      if repoCfg.url != ""
      then repoCfg.url
      else parsed.url;
    dir =
      if repoCfg.dir != ""
      then repoCfg.dir
      else parsed.dir;
    inherit (repoCfg) shallow links;
  };

  resolveLinkPath = p:
    if hasPrefix "/" p
    then p
    else if hasPrefix "~/" p
    then "${config.home.homeDirectory}/${removePrefix "~/" p}"
    else "${config.home.homeDirectory}/${p}";

  linkSubmodule = types.submodule {
    options = {
      path = mkOption {
        type = types.str;
        description = "Where to create the symlink. Relative paths resolve from $HOME; ~ expands to $HOME; absolute paths used as-is.";
      };
      target = mkOption {
        type = types.str;
        default = ".";
        description = "Relative path within the clone that the symlink points to.";
      };
    };
  };

  repoSubmodule = types.submodule {
    options = {
      url = mkOption {
        type = types.str;
        default = "";
        description = "Git clone URL. Derived from the attr name if empty.";
      };
      dir = mkOption {
        type = types.str;
        default = "";
        description = "Clone directory. Derived from the attr name if empty.";
      };
      shallow = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to create a shallow clone (--depth=1).";
      };
      links = mkOption {
        type = types.listOf linkSubmodule;
        default = [];
        description = "Symlinks to create pointing into this clone.";
      };
    };
  };
in {
  options.my.src-get = {
    enable = mkEnableOption "src-get repository manager";

    home = mkOption {
      type = types.str;
      default = config.my.userDirs.code;
      description = "Root directory for repository clones (SRC_HOME).";
    };

    defaultHost = mkOption {
      type = types.str;
      default = "github.com";
      description = "Default git host for 'owner/repo' shorthand.";
    };

    repos = mkOption {
      type = types.attrsOf repoSubmodule;
      default = {};
      description = "Git repos to ensure are cloned on activation. Attr name is the repo reference.";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables.SRC_HOME = cfg.home;

    my.shellInitExtra = ''
      source "${config.my.flakeDirectory}/bin/src-get"
    '';

    home.activation.srcGetRepos = mkIf (cfg.repos != {}) (
      hm.dag.entryAfter ["writeBoundary"] ''
        _git="${pkgs.git}/bin/git"

        ${concatStringsSep "\n" (
          mapAttrsToList (
            name: repoCfg: let
              r = resolveRepo name repoCfg;
            in ''
              # ${name}
              if ! [ -d "${r.dir}" ]; then
                run mkdir $VERBOSE_ARG -p "$(dirname "${r.dir}")"
                run $_git clone $VERBOSE_ARG ${optionalString r.shallow "--depth=1"} -- "${r.url}" "${r.dir}"
              fi
              ${concatMapStringsSep "\n" (
                  link: let
                    lp = resolveLinkPath link.path;
                  in ''
                    run mkdir $VERBOSE_ARG -p "$(dirname "${lp}")"
                    run ln $VERBOSE_ARG -sfn "${r.dir}/${link.target}" "${lp}"
                  ''
                )
                r.links}
            ''
          )
          cfg.repos
        )}
      ''
    );
  };
}
