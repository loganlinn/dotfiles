#!/usr/bin/env zsh

if [[ -z $STARSHIP_DISABLED ]]; then
	if ! (( $+commands[starship] )); then
		if read -q '?install starship? [y/N] '; then
			sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --verbose
		fi
	else
 		eval "$(starship init zsh)"
	fi
fi
