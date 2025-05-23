# https://github.com/nix-community/home-manager/tree/b23c7501f7e0a001486c9a5555a6c53ac7b08e85/modules/services/window-managers/i3-sway/lib/functions.nix
{lib, ...}:
with lib; {
  criteriaStr = criteria: let
    toCriteria = k: v:
      if builtins.isBool v
      then
        (
          if v
          then "${k}"
          else ""
        )
      else ''${k}="${v}"'';
  in "[${concatStringsSep " " (mapAttrsToList toCriteria criteria)}]";

  keybindingsStr = {
    keybindings,
    bindsymArgs ? "",
    indent ? "",
  }:
    concatStringsSep "\n" (mapAttrsToList
      (keycomb: action:
        optionalString (action != null) "${indent}bindsym ${
          lib.optionalString (bindsymArgs != "") "${bindsymArgs} "
        }${keycomb} ${action}")
      keybindings);

  keycodebindingsStr = keycodebindings:
    concatStringsSep "\n" (mapAttrsToList
      (keycomb: action:
        optionalString (action != null) "bindcode ${keycomb} ${action}")
      keycodebindings);

  modeStr = bindkeysToCode: name: keybindings: ''
    mode "${name}" {
    ${keybindingsStr {
      inherit keybindings;
      bindsymArgs = lib.optionalString bindkeysToCode "--to-code";
      indent = "  ";
    }}
    }
  '';

  assignStr = workspace: criteria:
    concatStringsSep "\n"
    (map (c: "assign ${criteriaStr c} ${workspace}") criteria);

  fontConfigStr = let
    toFontStr = {
      names,
      style ? "",
      size ? "",
    }:
      optionalString (names != []) concatStringsSep " "
      (remove "" ["font" "pango:${concatStringsSep ", " names}" style size]);
  in
    fontCfg:
      if isList fontCfg
      then toFontStr {names = fontCfg;}
      else
        toFontStr {
          inherit (fontCfg) names style;
          size = toString fontCfg.size;
        };

  trim = str: (flip pipe) [(removePrefix str) (removeSuffix str)];

  floatingCriteriaStr = criteria: "for_window ${criteriaStr criteria} floating enable";

  windowCommandsStr = {
    command,
    criteria,
    ...
  }: "for_window ${criteriaStr criteria} ${command}";

  workspaceOutputStr = item: ''workspace "${trim "\"" item.workspace}" output "${item.output}"'';
}
