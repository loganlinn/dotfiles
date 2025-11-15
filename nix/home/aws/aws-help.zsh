# aws-help.zsh: Wrapper to add hyperlinks to AWS CLI help output

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

		# Run aws command and pipe through linkifier
		command aws "$@" | aws-help-linkify "$service" "$command"
	else
		# Not a help command, pass through normally
		command aws "$@"
	fi
}
