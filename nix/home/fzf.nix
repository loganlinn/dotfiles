{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  walker-skip-dirs = [
    ".cache"
    ".direnv"
    ".git"
    "node_modules"
  ];
  walker-skip-option = "--walker-skip=[${builtins.concatStringsSep "," walker-skip-dirs}]";
  termcopy = pkgs.writeShellScriptBin "termcopy" ../../bin/termcopy;
in
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    tmux.enableShellIntegration = config.programs.tmux.enable;
    defaultOptions = lib.warnIf (!config ? colorScheme) "Missing config.colorScheme" (
      lib.mkIf (config ? colorScheme) (
        with config.colorScheme.palette;
        [
          "--multi"
          "--layout=reverse"
          "--highlight-line"
          "--inline-info"
          "--border"
          "--cycle"
          "--color 'bg:#${base00}'"
          "--color 'fg:#${base05}'"
          "--color 'preview-fg:#${base05}'"
          "--color 'preview-bg:#${base00}'"
          "--color 'hl:#${base0A}'" # Highlighted substrings
          "--color 'bg+:#${base02}'" # Background (current line)
          "--color 'fg+:#${base06}'" # Text (current line)
          "--color 'gutter:#${base04}'" # Gutter on the left (defaults to bg+)
          "--color 'hl+:#${base0E}'" # Highlighted substrings (current line)
          "--color 'info:#${base05}'" # Info line (match counters)
          "--color 'border:#${base01}'" # Border around the window (--border and --preview)
          "--color 'prompt:#${base01}'" # Prompt
          "--color 'pointer:#${base0E}'" # Pointer to the current line
          "--color 'marker:#${base0E}'" # Multi-select marker
          "--color 'spinner:#${base0E}'" # Streaming input indicator
          "--color 'header:#${base0D}'" # Header
          "--bind='ctrl-g:jump'"
          "--bind='esc:close'"
          "--bind='f5:refresh-preview'"
          "--bind='ctrl-\:become(${pkgs.moreutils}/bin/vipe <<< {})"
        ]
      )
    );

    fileWidgetOptions = [
      walker-skip-option
      "--preview='${pkgs.bat}/bin/bat --color=always --style=numbers {}'"
    ];

    changeDirWidgetOptions = [
      walker-skip-option
      "--preview='${pkgs.eza}/bin/eza --color=always --tree --level=3 --classify=never --width=$FZF_PREVIEW_COLUMNS {}'"
    ];

    historyWidgetOptions = [
      "--sort"
      "--exact"
      "--preview='echo -n {2..} | ${pkgs.bat}/bin/bat --color=always --plain --language=bash'"
      "--preview-window up:3"
      "--bind='ctrl-y:execute-silent(echo -n {2..} | ${termcopy})+abort'"
    ];
  };

  my.shellInitExtra = ''
    source ${inputs.fzf-git}/share/fzf-git-sh/fzf-git.sh
  '';
}
