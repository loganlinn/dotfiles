{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  json = pkgs.formats.json { };
  cfg = config.programs.claude;
in
{
  imports = [ ./desktop.nix ];

  options = {
    programs.claude = {
      enable = mkEnableOption "claude";
      code = {
        enable = mkEnableOption "Claude Code" // {
          default = true;
        };
      };
      developer = {
        settings = mkOption {
          type = types.attrsOf json.type;
          default = { };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional cfg.code.enable pkgs.claude-code;
    home.file = optionalAttrs (cfg.developer.settings != { } && pkgs.stdenv.isDarwin) {
      "Library/Application Support/Claude/developer_settings.json".source =
        json.generate "developer_settings.json" cfg.developer.settings;
    };
    home.sessionVariables = mkIf cfg.code.enable {
      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
      CLAUDE_CODE_ENABLE_AWAY_SUMMARY = "0";
      CLAUDE_CODE_ENABLE_TASKS = "1";
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      # CLAUDE_CODE_SHELL_PREFIX = "";
      # CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "1";
    };
    home.shellAliases = mkIf cfg.code.enable {
      cl = "claude";
      clc = "claude --continue";
      clr = "claude --resume";
      cla = "claude --allow-dangerously-skip-permissions";
      clcd = "mkdir -p ~/.claude && cd ~/.claude";
      clsettings = "editor ~/.claude/settings.json";
      clmcp = "editor ~/.claude/claude.json";
      clmemory = "editor ~/.claude/CLAUDE.md";
      clres = "claude --resume";
      clplan = "claude --permission-mode plan";
      yolo = "claude --dangerously-skip-permissions";
      sonnet = "claude --model sonnet";
      opus = "claude --model opus";
      haiku = "claude --model haiku";
      opusplan = "claude --model opusplan";
      cldots = ''cd "''${DOTFILES_DIR:-$HOME/.dotfiles}" && claude'';
      claude-simple = "CLAUDE_CODE_SIMPLE=1 claude";
    };
    programs.zsh.initContent = mkIf cfg.code.enable ''
      function claude() {
        local chdir=.
        local system_prompt=

        local git_toplevel=
        local git_prefix=
        if git_toplevel=$(git rev-parse --show-toplevel 2>/dev/null); then
          git_prefix=$(git rev-parse --show-prefix 2>/dev/null)
          system_prompt="User initiated from <GIT_PREFIX>$git_prefix</GIT_PREFIX> of <GIT_TOPLEVEL>$git_toplevel</GIT_TOPLEVEL>. Prioritize the file tree at <GIT_TOPLEVEL>/<GIT_PREFIX> when interpreting user prompts."
          chdir=$git_toplevel
        fi

        local -a claude_cmd=(
          "''${commands[claude]:-claude}"
          --allow-dangerously-skip-permissions
          --append-system-prompt "$system_prompt"
          "$@"
        )

        ${pkgs.coreutils-full}/bin/env \
          --chdir="$chdir" \
          --unset=ANTHROPIC_API_KEY \
          -S DISABLE_ERROR_REPORTING=1 \
          "''${claude_cmd[@]}"
      }
    '';
  };
}
