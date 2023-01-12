#!/usr/bin/env bash

### AUTHOR:         Johann Birnick (github: jbirnick), Logan Linn (github: loganlinn)
### PROJECT REPO:   https://github.com/jbirnick/polybar-timer

set -e

readonly TIMER=${XDG_RUNTIME_DIR:-/tmp}/polybar-timer
readonly ACTION=${ACTION_DIR}/action
readonly PAUSED=${TIMER}/paused
readonly EXPIRY=${TIMER}/expiry
readonly LABEL_RUNNING=${TIMER}/label_running
readonly LABEL_PAUSED=${TIMER}/label_paused
readonly NOTIFICATION_ID=1673464423

## FUNCTIONS

now() { date --utc +%s; }

timerSet() { [[ -e $TIMER ]]; }
timerPaused() { timerSet && [[ -f $PAUSED ]]; }

killTimer() { ! timerSet || rm -rf "$TIMER"; }

timerExpiry() { cat "$EXPIRY"; }
timerLabelRunning() { cat "$LABEL_RUNNING"; }
timerLabelPaused() { cat "$LABEL_PAUSED"; }
timerAction() { cat "$LABEL_ACTION"; }

secondsLeftWhenPaused() { cat "$PAUSED"; }
minutesLeftWhenPaused() { echo $((($(secondsLeftWhenPaused) + 59) / 60)); }

secondsLeft() { echo $(($(timerExpiry) - $(now))); }
minutesLeft() { echo $((($(secondsLeft) + 59) / 60)); }

printExpiryTime() { dunstify -u low -r "$NOTIFICATION_ID" "Timer expires at $(date -d "$(secondsLeft) sec" +%H:%M)"; }
printPaused() { dunstify -u low -r "$NOTIFICATION_ID" "Timer paused"; }
clearNotification() { dunstify -C "$NOTIFICATION_ID"; }

cleanup() {
	killTimer
	clearNotification
}

updateTail() {
	# check whether timer is expired
	if timerSet; then
		if { timerPaused && [[ $(minutesLeftWhenPaused) -le 0 ]]; } ||
			{ ! timerPaused && [[ $(minutesLeft) -le 0 ]]; }; then
			eval "$(timerAction)"
			killTimer
			clearNotification
		fi
	fi

	# update output
	if timerSet; then
		if timerPaused; then
			printf "%s %s" "$(timerLabelPaused)" "$(minutesLeftWhenPaused)"
		else
			printf "%s %s" "$(timerLabelRunning)" "$(minutesLeft)"
		fi
	else
		printf %s "${STANDBY_LABEL}"
	fi
}

expectArgCount() {
	local n=$1
	shift
	if [[ $# -ne $n ]]; then
		echo >&2 "Unexpected number of args: $n. Got $#."
		exit 1
	fi
}

## MAIN CODE

case $1 in
tail)
	expectArgCount 3

	STANDBY_LABEL=$2

	trap updateTail USR1

	while true; do
		updateTail
		sleep "$3" &
		wait
	done
	;;

update)
	expectArgCount 2
	kill -USR1 "$(pgrep --oldest --parent "$2")"
	;;

new)
	expectArgCount 5
	killTimer
	mkdir -p "$TIMER"
	echo "$(($(now) + 60 * ${2}))" >"$EXPIRY"
	"$LABEL_RUNNING" <<<"$3"
	"$LABEL_PAUSED" <<<"$4"
	"$ACTION" <<<"$5"
	printExpiryTime
	;;

increase)
	expectArgCount 2
	timerSet || exit 1
	if timerPaused; then
		printf %s "$(($(secondsLeftWhenPaused) + ${2}))" >"$PAUSED"
	else
		printf %s "$(($(timerExpiry) + ${2}))" >"$EXPIRY"
		printExpiryTime
	fi
	;;

cancel)
	killTimer
	clearNotification
	;;

togglepause)
	if timerSet; then
		if timerPaused; then
			printf %s "$(($(now) + $(secondsLeftWhenPaused)))" >"$EXPIRY"
			rm -f "$TIMER"/paused
			printExpiryTime
		else
			secondsLeft >"$TIMER"/paused
			rm -f "$TIMER"/expiry
			printPaused
		fi
	else
		exit 1
	fi
	;;

*)
	echo "Please read the manual at https://github.com/jbirnick/polybar-timer ."
	;;
esac
