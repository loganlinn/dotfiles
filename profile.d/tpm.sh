#!/usr/bin/env sh

tpm() {
	if [ -z "$TMUX_PLUGIN_MANAGER_PATH" ]; then
		if [ -f "$XDG_CONFIG_HOME"/tmux/tmux.conf ]; then
			TMUX_PLUGIN_MANAGER_PATH="$XDG_CONFIG_HOME"/tmux/plugins
		else
			TMUX_PLUGIN_MANAGER_PATH="$HOME"/.tmux/plugins
		fi
	fi
	if ! [ -d "$TMUX_PLUGIN_MANAGER_PATH"/tpm ]; then
		echo "no tpm installation found at '$TMUX_PLUGIN_MANAGER_PATH/tpm': No such directory" >&2
		echo "Try 'git clone https://github.com/tmux-plugins/tpm $TMUX_PLUGIN_MANAGER_PATH/tpm' to install" >&2
    return 1
	fi
	# shellcheck disable=SC2145
	"$TMUX_PLUGIN_MANAGER_PATH"/tpm/bin/"$@"
}
