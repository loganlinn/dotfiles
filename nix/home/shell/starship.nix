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
        # "$singularity"
        # "$kubernetes"
        "$directory"
        "$aws"
        # "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_state"
        # "$git_metrics" # note: disabled by default
        # "$git_status"
        # "$hg_branch"
        # "$docker_context"
        # "$package"
        # "$bun"
        # "$c"
        # "$cmake"
        # "$cobol"
        # "$daml"
        # "$dart"
        # "$deno"
        # "$dotnet"
        # "$elixir"
        # "$elm"
        # "$erlang"
        # "$golang"
        # "$haskell"
        # "$haxe"
        # "$helm"
        # "$java"
        # "$julia"
        # "$kotlin"
        # "$lua"
        # "$nim"
        # "$nodejs"
        # "$ocaml"
        # "$opa"
        # "$perl"
        # "$php"
        # "$pulumi"
        # "$purescript"
        # "$python"
        # "$raku"
        # "$rlang"
        # "$red"
        # "$ruby"
        # "$rust"
        # "$scala"
        # "$swift"
        # "$terraform"
        # "$vlang"
        # "$vagrant"
        # "$zig"
        # "$buf"
        # "$guix_shell"
        "$nix_shell"
        # "$conda"
        # "$meson"
        # "$spack"
        # "$memory_usage"
        # "$gcloud"
        # "$openstack"
        # "$azure"
        # "$crystal"
        "$custom"
        "$sudo"
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
      git_commit = {
        format = "[\($hash$tag\)]($style) ";
        disabled = false;
        only_detached = false;
        tag_disabled = false;
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
