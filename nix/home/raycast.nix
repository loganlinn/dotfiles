{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.raycast;

  inherit (lib)
    concatMapStringsSep
    concatStringsSep
    escapeShellArg
    filterAttrs
    hasPrefix
    imap1
    literalExpression
    mapAttrs'
    mkEnableOption
    mkIf
    mkOption
    nameValuePair
    optional
    optionalAttrs
    removePrefix
    types
    ;

  argumentSubmodule = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [
          "dropdown"
          "password"
          "text"
        ];
        default = "text";
        description = "Input type of the argument.";
      };
      placeholder = mkOption {
        type = types.str;
        description = "Prompt text shown in the argument field.";
      };
      optional = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the argument is optional. Defaults to required.";
      };
      percentEncoded = mkOption {
        type = types.bool;
        default = false;
        description = "URL-encode the argument before passing it to the script.";
      };
      data = mkOption {
        type = types.nullOr (
          types.listOf (types.submodule {
            options = {
              title = mkOption {
                type = types.str;
                description = "Label shown in the dropdown.";
              };
              value = mkOption {
                type = types.str;
                description = "Value passed to the script when the entry is selected.";
              };
            };
          })
        );
        default = null;
        description = ''Dropdown options. Required when `type = "dropdown"`.'';
      };
    };
  };

  scriptCommandSubmodule = types.submodule (
    { name, ... }:
    {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether this script command is generated.";
        };

        fileName = mkOption {
          type = types.str;
          default = name;
          defaultText = literalExpression "<attribute name>";
          description = "File name (without extension) under the script command directory.";
        };

        extension = mkOption {
          type = types.str;
          default = "sh";
          description = "File extension. Raycast uses this to pick an interpreter.";
        };

        interpreter = mkOption {
          type = types.str;
          default = "/usr/bin/env bash";
          description = "Shebang used on the first line of the generated script (without leading `#!`).";
        };

        schemaVersion = mkOption {
          type = types.ints.positive;
          default = 1;
          description = "Schema version of the Raycast script command API.";
        };

        title = mkOption {
          type = types.str;
          description = "Display name shown as the title in Raycast root search.";
        };

        mode = mkOption {
          type = types.enum [
            "compact"
            "fullOutput"
            "inline"
            "silent"
          ];
          description = ''
            How the script is executed and how its output is presented.

            - `silent`: last line shown in an HUD toast after Raycast closes.
            - `compact`: last line shown in a toast inside Raycast.
            - `fullOutput`: full output rendered in a separate view.
            - `inline`: first line shown in the command item itself, refreshing per `refreshTime`.
          '';
        };

        packageName = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Subtitle shown next to the command. Defaults to the parent directory name.";
        };

        icon = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Emoji, local file path, or HTTPS URL of the icon.";
        };

        iconDark = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Dark-mode variant of the icon. Defaults to `icon`.";
        };

        currentDirectoryPath = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Working directory used when executing the script.";
        };

        needsConfirmation = mkOption {
          type = types.bool;
          default = false;
          description = "Whether Raycast prompts for confirmation before running.";
        };

        refreshTime = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "10s";
          description = ''
            Refresh interval for `inline` mode. Minimum `10s`.
            Formats: `Ns`, `Nm`, `Nh`, `Nd`.
          '';
        };

        author = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Author of the script, shown in Raycast's documentation view.";
        };

        authorURL = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Contact URL for the author.";
        };

        description = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Short description shown in Raycast's documentation view.";
        };

        arguments = mkOption {
          type = types.listOf argumentSubmodule;
          default = [ ];
          description = ''
            Up to 3 arguments prompted for in the Raycast search bar.
            Referenced in the script as `$1`, `$2`, `$3`.
          '';
        };

        runtimeInputs = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = ''
            Packages whose `bin` directories are prepended to `PATH`
            inside the generated script. Useful when the script depends
            on tools installed via Nix that may not be on the `PATH`
            that Raycast inherits from `launchd`.
          '';
        };

        script = mkOption {
          type = types.lines;
          description = "Body of the script, placed after the metadata block.";
        };
      };
    }
  );

  enabledCommands = filterAttrs (_: sc: sc.enable) cfg.scriptCommands;

  renderArgumentJSON =
    arg:
    let
      attrs =
        {
          inherit (arg) type placeholder;
        }
        // optionalAttrs arg.optional { optional = true; }
        // optionalAttrs arg.percentEncoded { percentEncoded = true; }
        // optionalAttrs (arg.data != null) {
          data = map (d: { inherit (d) title value; }) arg.data;
        };
    in
    builtins.toJSON attrs;

  metadataLine = key: value: "# @raycast.${key} ${value}";

  requiredMetadata = sc: [
    (metadataLine "schemaVersion" (toString sc.schemaVersion))
    (metadataLine "title" sc.title)
    (metadataLine "mode" sc.mode)
  ];

  optionalMetadata =
    sc:
    optional (sc.packageName != null) (metadataLine "packageName" sc.packageName)
    ++ optional (sc.icon != null) (metadataLine "icon" sc.icon)
    ++ optional (sc.iconDark != null) (metadataLine "iconDark" sc.iconDark)
    ++ optional (sc.currentDirectoryPath != null) (
      metadataLine "currentDirectoryPath" sc.currentDirectoryPath
    )
    ++ optional sc.needsConfirmation (metadataLine "needsConfirmation" "true")
    ++ optional (sc.refreshTime != null) (metadataLine "refreshTime" sc.refreshTime)
    ++ imap1 (i: a: metadataLine "argument${toString i}" (renderArgumentJSON a)) sc.arguments;

  documentationMetadata =
    sc:
    optional (sc.author != null) (metadataLine "author" sc.author)
    ++ optional (sc.authorURL != null) (metadataLine "authorURL" sc.authorURL)
    ++ optional (sc.description != null) (metadataLine "description" sc.description);

  renderSection =
    header: lines:
    if lines == [ ] then "" else "# ${header}:\n${concatStringsSep "\n" lines}\n";

  renderPathPrefix =
    sc:
    if sc.runtimeInputs == [ ] then
      ""
    else
      let
        bins = concatMapStringsSep ":" (p: "${p}/bin") sc.runtimeInputs;
      in
      "export PATH=${escapeShellArg bins}\${PATH:+:}\${PATH:-}\n\n";

  renderScriptCommand =
    sc:
    let
      required = renderSection "Required parameters" (requiredMetadata sc);
      optionalMd = renderSection "Optional parameters" (optionalMetadata sc);
      docMd = renderSection "Documentation" (documentationMetadata sc);
      sections = lib.filter (s: s != "") [
        required
        optionalMd
        docMd
      ];
    in
    ''
      #!${sc.interpreter}

      ${concatStringsSep "\n" sections}
      ${renderPathPrefix sc}${sc.script}
    '';

  relScriptDir = removePrefix "${config.home.homeDirectory}/" cfg.scriptCommandDirectory;

  mkFileEntry =
    sc:
    nameValuePair "${relScriptDir}/${sc.fileName}.${sc.extension}" {
      text = renderScriptCommand sc;
      executable = true;
    };

in
{
  options.programs.raycast = {
    enable = mkEnableOption "Raycast script command integration";

    scriptCommandDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.local/share/raycast/scripts";
      defaultText = literalExpression ''"''${config.home.homeDirectory}/.local/share/raycast/scripts"'';
      description = ''
        Absolute path to the directory where script commands are written.
        Raycast must be configured to watch this directory
        (Raycast → Extensions → Script Commands → "Add Directories").
        Must be under `config.home.homeDirectory`.
      '';
    };

    scriptCommands = mkOption {
      type = types.attrsOf scriptCommandSubmodule;
      default = { };
      description = "Raycast script commands generated by home-manager.";
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    assertions = [
      {
        assertion = hasPrefix "${config.home.homeDirectory}/" cfg.scriptCommandDirectory;
        message = "programs.raycast.scriptCommandDirectory must be under ${config.home.homeDirectory}.";
      }
    ];

    home.file = mapAttrs' (_: mkFileEntry) enabledCommands;
  };
}
