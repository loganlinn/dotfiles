{ lib, ... }:
let
  inherit (lib) concatStrings;
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    enableFishIntegration = true;
    settings = {
      profiles = {
        claude-code = concatStrings [
          "$claude_model"
          "$claude_context"
          "$claude_cost"
          "$git_branch"
          "$aws"
        ];
      };
      format = concatStrings [
        "$username"
        "$hostname"
        # "$localip"
        "$shlvl"
        "$nix_shell"
        # "$singularity"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        # "$git_status"
        "$aws"
        "$kubernetes"
        "$cmd_duration"
        "$line_break"
        ########################################################################
        "$vi_mode"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$container"
        "$os"
        # "$env_var"
        "$shell"
        "$character"
      ];
      aws = {
        format = "[$symbol$profile]($style) ";
        symbol = "  ";
      };
      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };
      git_commit = {
        format = "[\($hash$tag\)]($style) ";
        disabled = false;
        only_detached = false;
        tag_disabled = false;
      };
      kubernetes = {
        format = "[$symbol$context(:$namespace)]($style) ";
      };
      claude_model = {
        format = "[$symbol$model]($style) ";
        symbol = "🤖 ";
        style = "bold blue";
        model_aliases = {
        };
        disabled = false;
      };
      claude_context = {
        format = "[$gauge $percentage]($style) ";
        symbol = "";
        gauge_width = 10;
        # gauge_full_symbol = "█";
        # gauge_partial_symbol = "▒";
        # gauge_empty_symbol = "░";
        gauge_full_symbol = "▰";
        gauge_partial_symbol = "";
        gauge_empty_symbol = "▱";
        display = [
          {
            threshold = 0;
            hidden = true;
          }
          {
            threshold = 30;
            style = "bold green";
          }
          {
            threshold = 60;
            style = "bold yellow";
          }
          {
            threshold = 80;
            style = "bold red";
          }
        ];
        disabled = false;
      };
      claude_cost = {
        format = "[$symbol$cost]($style) ";
        symbol = "💸";
        disabled = false;
      };
    };
  };
}
