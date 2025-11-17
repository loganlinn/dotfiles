# aws-help-linkify.plugin.zsh: Add terminal hyperlinks to AWS CLI help output
#
# This plugin wraps the `aws` command to automatically add clickable hyperlinks
# to AWS help pages, making it easy to navigate between services and commands.

# Add plugin's bin directory to PATH and save its location
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="$(builtin cd -q -- "${0:A:h}" && builtin pwd -P)"
AWS_HELP_LINKIFY_BIN_DIR="${0}/bin"
path=("${AWS_HELP_LINKIFY_BIN_DIR}" $path)

# Wrapper function for aws command
aws() {
  # Check if the last argument is "help"
  local args=("$@")
  local last_arg="${args[-1]}"

  if [[ "$last_arg" == "help" ]]; then
    # Extract service and command from arguments
    local service=""
    local command=""

    # Parse arguments to identify service and command
    # Format: aws [global-opts] <service> [service-opts] <command> [command-opts] help
    local i=1
    while [[ $i -le ${#args[@]} ]]; do
      local arg="${args[$i]}"

      # Skip global options and their values
      if [[ "$arg" =~ ^-- ]]; then
        ((i++))
        # Check if this option takes a value (simple heuristic: if next arg doesn't start with -)
        if [[ $i -le ${#args[@]} && ! "${args[$i]}" =~ ^- ]]; then
          ((i++))
        fi
        continue
      fi

      # First non-option argument is the service (unless it's "help")
      if [[ -z "$service" && "$arg" != "help" ]]; then
        service="$arg"
        ((i++))
        continue
      fi

      # Second non-option argument is the command (unless it's "help")
      if [[ -n "$service" && -z "$command" && "$arg" != "help" ]]; then
        command="$arg"
        break
      fi

      ((i++))
    done

    local pager="${MANPAGER:-${PAGER:-less -R}}"
    MANPAGER="${AWS_HELP_LINKIFY_BIN_DIR}/aws-help-linkify" command aws "$@"

    # Set context for the pager wrapper and use our custom pager
    # Note: `aws help` uses MANPAGER, not PAGER or AWS_PAGER!
    # Save original pager (check MANPAGER first, then PAGER) so aws-help-pager can use it
    # Use absolute path because Nix's aws wrapper resets PATH
    # Don't use 'command' builtin - let the wrapper run normally
    # AWS_HELP_SERVICE="$service" AWS_HELP_COMMAND="$command" AWS_HELP_MANPAGER="${MANPAGER:-${PAGER:-less -R}}" MANPAGER="${AWS_HELP_LINKIFY_BIN_DIR}/aws-help-pager" command aws "$@"
  else
    command aws "$@"
  fi
}
