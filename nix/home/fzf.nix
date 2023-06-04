{ config, lib, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    tmux.enableShellIntegration = config.programs.tmux.enable;
    defaultOptions = with config.colorScheme.colors; [
      "--layout=reverse"
      "--border"
      "--inline-info"
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
    ];
  };
}
