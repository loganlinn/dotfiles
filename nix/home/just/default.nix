{ config
, lib
, pkgs
, ...
}:
with lib; let
  # primitiveType = with types; oneOf [ str boolean number ];

  # settingValueType = with types; (nullOr (either primitiveType (listOf primitiveType)));

  # settingsType = types.attrsOf settingValueType;

  # recipeType = with types;
  #   submodule {
  #     options = {
  #       packages = mkOption {
  #         type = listOf package;
  #         default = [ ];
  #       };
  #       name = mkOption {
  #         type = nonEmptyStr;
  #       };
  #       attributes = mkOption {
  #         type = listOf str;
  #         default = [ ];
  #       };
  #       text = mkOption {
  #         type = str;
  #       };
  #     };
  #   };

  # justfileType = with types;
  #   submodule {
  #     options = {
  #       shell = mkOption {
  #         type = nullOr (either package (listOf str));
  #         default = null;
  #       };
  #       packages = mkOption {
  #         type = listOf package;
  #         default = [ ];
  #       };
  #       aliases = mkOption {
  #         type = attrsOf str;
  #         default = { };
  #       };
  #       text = mkOption {
  #         type = lines;
  #         default = "";
  #       };
  #     };
  #   };

  # justfileShebang =
  #   if pkgs.stdenv.isLinux
  #   then "#!/usr/bin/env -S just --justfile"
  #   else "#!/usr/bin/env just --justfile";

  # # https://github.com/casey/just/blob/f04de756091028dd8fe31773e5f65e16d8f177ed/GRAMMAR.md
  # tokenRegexes = {
  #   CONDITIONAL = concatStringsSep "[[:space:]]+" [ "if" "(.+)" "\\{" "(.+)" "}" "else" "\\{" "(.+)" "}" ];
  #   BACKTICKS = "`([^`]*)`";
  #   INDENTED_BACKTICKS = "```([^(```)]*)```";
  #   NAME = "([a-zA-Z_][a-zA-Z0-9_-]*)";
  #   RAW_STRING = "'([^']*)'";
  #   INDENTED_RAW_STRING = "'''([^(''')]*)'''";
  #   STRING = ''"([^"]*)"'';
  #   INDENTED_STRING = ''"""([^(""")]*)"""'';
  #   LINE_PREFIX = "@-|-@|@|-";
  #   COMMENT = "#([^!].*)?$";
  # };

  # matchToken = value:
  #   head (filter (pair: pair.match != null) (mapAttrsToList
  #     (name: regex: {
  #       inherit name value;
  #       match = builtins.match regex value;
  #     })
  #     tokenRegexes));

  cfg = config.my.just;
in
{
  options.my.just = {
    enableZshCompletion = (mkEnableOption "Whether to enable Zsh completion.") // { default = config.programs.zsh.enableCompletion; };

    enableBashCompletion = (mkEnableOption "Whether to enable Bash completion.") // { default = config.programs.bash.enableCompletion; };

    # justfile = mkOption {
    #   type = types.nullOr justfileType;
    #   default = null;
    # };
  };

  config = {
    home.packages = [ pkgs.just ];

    # home.shellAliases = mkIf (cfg.justfile != null) {
    #   ".j" = ''just --justfile "${config.xdg.dataHome}/just/user.justfile" --working-directory .'';
    # };

    # programs.zsh.initExtra = mkIf cfg.enableZshCompletion ''
    #   compdef _just .j
    # '';

    # programs.bash.initExtra = mkIf cfg.enableBashCompletion ''
    #   complete -F _just -o bashdefault -o default .j
    # '';

    # xdg.dataFile."just/user.justfile" = mkIf (cfg.justfile != null) {
    #   executable = true;
    #   text =
    #     concatStringsSep "\n\n"
    #       [
    #         justfileShebang
    #       ]
    #     ++ optional (cfg.justfile.packages != [ ]) ''export PATH := "${makeBinPath cfg.justfile.packages}:$PATH"''
    #     ++ [
    #       "set shell := ${builtins.toJSON (map toString (toList shell))}"
    #       cfg.justfile.text
    #     ];
    # };
  };
}
