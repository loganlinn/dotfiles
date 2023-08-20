{
  config,
  pkgs,
  ...
}: {
  programs.readline = {
    enable = true;
    bindings = {
      "\\t" = "menu-complete";
      "\\e[Z" = "menu-complete-backward";
      "\\C-w" = "backward-kill-word";
    };
    variables = {
      "blink-matching-paren" = "on";
      "colored-stats" = "on";
      "completion-display-width" = 4;
      "completion-ignore-case" = "on";
      "enable-bracketed-paste" = "on";
      "show-all-if-ambiguous" = "on";
    };
  };
}
