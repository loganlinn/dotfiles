{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    enableFishIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$localip"
        "$shlvl"
        # "$singularity"
        # "$kubernetes"
        "$directory"
        # "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics" # note: disabled by default
        "$git_status"
        # "$hg_branch"
        "$docker_context"
        "$package"
        # "$bun"
        "$c"
        "$cmake"
        # "$cobol"
        # "$daml"
        # "$dart"
        "$deno"
        "$dotnet"
        "$elixir"
        "$elm"
        "$erlang"
        "$golang"
        "$haskell"
        # "$haxe"
        # "$helm"
        "$java"
        "$julia"
        # "$kotlin"
        "$lua"
        # "$nim"
        "$nodejs"
        # "$ocaml"
        # "$opa"
        # "$perl"
        # "$php"
        # "$pulumi"
        # "$purescript"
        "$python"
        # "$raku"
        # "$rlang"
        # "$red"
        # "$ruby"
        "$rust"
        "$scala"
        "$swift"
        "$terraform"
        "$vlang"
        # "$vagrant"
        "$zig"
        # "$buf"
        "$guix_shell"
        "$nix_shell"
        "$conda"
        "$meson"
        "$spack"
        # "$memory_usage"
        "$aws"
        # "$gcloud"
        "$openstack"
        "$azure"
        "$env_var"
        "$crystal"
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
        "$shell"
        "$character"
      ];
      git_commit = {
        disabled = false;
        only_detached = false;
      };
    };
  };
}
