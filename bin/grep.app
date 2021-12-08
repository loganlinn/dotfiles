#!/usr/bin/env bash

readonly PROG
#######################################
main() {
	parse_command "$@"
  run_command
}

#######################################
usage() {
	cat <<-USAGE 1>&2
		    Search across a half million git repos. Opens https://grep.app search in web browser.

				Usage:
				  $0 [FLAGS] QUERY
				Flags:
         -l, --language LANG          Filter by programming language
         -R, --repo OWNER/REPO        Filter by owner/repo
         -s, --case-sensitive         Search case sensitively
         -e, --regexp                 Interpret QUERY as regular expression
         -w, --word                   Search matches surrounded by word boundary
         -d, --debug                  Enable debug in output
         -h, --help                   Help for $0
	USAGE
}

#######################################
err() {
	echo "error: $*" >&2
}

#######################################
# Globals:
#   PARSED_ARGUMENTS
#   OPT_DEBUG
#   OPT_FILTER_LANG
#   OPT_FILTER_REPO
#   OPT_CASE
#   OPT_WORDS
#   OPT_REGEXP
#   ARG_QUERY
#######################################
parse_command() {
	get_getopt

	PARSED_ARGUMENTS=$(
		$GETOPT_CMD \
			--name "grep.app" \
			--options l:R:dh \
			--long language:,repo:,help,debug \
			-- "$@"
	) || {
		usage
		exit 1
	}

	eval set -- "$PARSED_ARGUMENTS"

	## Defaults
	OPT_FILTER_LANG=()
	OPT_FILTER_REPO=()
	OPT_DEBUG=false
	OPT_CASE=false
	OPT_WORDS=false
	OPT_REGEXP=false
	ARG_QUERY=

	## Process Agurments
	while true; do
		case "$1" in
		-l | --language)
			OPT_FILTER_LANG+=("$2")
			shift 2
			;;
		-R | --repo)
			OPT_FILTER_REPO+=("$2")
			shift 2
			;;
		-d | --debug)
			OPT_DEBUG=true
			shift
			;;
		-s | --case-sensitive)
			OPT_CASE=true
			shift
			;;
		-w | --word)
			OPT_WORDS=true
			shift
			;;
		-e | --regexp)
			OPT_REGEXP=true
			shift
			;;
		-h | --help)
			usage
			exit
			;;
		--)
			shift
			break
			;;
		*) break ;;
		esac
	done

	ARG_QUERY="$*"

  readonly OPT_CASE
  readonly OPT_REGEXP
  readonly OPT_WORDS
  readonly OPT_FILTER_LANG
  readonly OPT_FILTER_REPO
  readonly OPT_DEBUG
  readonly ARG_QUERY
}

#######################################
# Find GNU getopt or print error message
# Globals:
#   GETOPT_CMD
#######################################
get_getopt() {
	unset GETOPT_CMD
	## Check for GNU getopt compatibility
	if [[ "$(getopt --version)" =~ "--" ]]; then
		local kernel
		local message
		kernel="$(uname -s)"
		kernel="${kernel,,}"
		case "$kernel" in
		darwin)
			## Check HomeBrew install location
			if [[ -f "/usr/local/opt/gnu-getopt/bin/getopt" ]]; then
				GETOPT_CMD="/usr/local/opt/gnu-getopt/bin/getopt"
			## Check MacPorts install location
			elif [[ -f "/opt/local/bin/getopt" ]]; then
				GETOPT_CMD="/opt/local/bin/getopt"
			fi
			;;
		freebsd)
			## Check FreeBSD install location
			if [[ -f "/usr/local/bin/getopt" ]]; then
				GETOPT_CMD="/usr/local/bin/getopt"
			fi
			;;
		esac
	else
		GETOPT_CMD="$(builtin command -v getopt)"
	fi
	## Error if no suitable getopt command found
	if [[ -z $GETOPT_CMD ]]; then
		err "GNU getopt not found. Please install GNU compatible 'getopt'" "\n\n" "$message"
		exit 1
	fi
}

#######################################
run_command() {
  set -e
  if [[ $OPT_DEBUG == true ]]; then
    set -x
  fi

  construct_url
  open_url
}

#######################################
# Constructs URL
# Globals:
#   OPEN_URL
#######################################
construct_url() {
	OPEN_URL=https://grep.app

	# if no query, fallback to homepage
	if [[ -z $ARG_QUERY ]]; then
		return
	fi

	local i
	OPEN_URL+="/search?q=$ARG_QUERY"
	[[ $OPT_WORDS != true ]] || OPEN_URL+="&words=$OPT_WORDS"
	[[ $OPT_CASE != true ]] || OPEN_URL+="&case=$OPT_CASE"
	[[ $OPT_REGEXP != true ]] || OPEN_URL+="&regexp=$OPT_REGEXP"
	for i in "${!OPT_FILTER_LANG[@]}"; do
		OPEN_URL+="&filter[lang][$i]=${OPT_FILTER_LANG[i]}"
	done
	for i in "${!OPT_FILTER_REPO[@]}"; do
		OPEN_URL+="&filter[repo][$i]=${OPT_FILTER_REPO[i]}"
	done
}

#######################################
# Opens URL in default (web browser) application
# Globals:
#   OPEN_URL
#######################################
open_url() {
	[[ -n "$OPEN_URL" ]] || return

  echo "Opening $OPEN_URL in your browser..."
  if [[ $DESKTOP_SESSION == gnome ]] && builtin command -v gnome-open >/dev/null; then
    gnome-open "$OPEN_URL" &>/dev/null
  elif [[ -n $XDG_SESSION_TYPE ]] && builtin command -v xdg-open >/dev/null; then
    xdg-open "$OPEN_URL" &>/dev/null
  elif [[ $OSTYPE = darwin* ]] && builtin command -v open >/dev/null; then
    open "$OPEN_URL"
  elif uname -a | grep -i -q Microsoft && builtin command -v powershell.exe >/dev/null; then
			powershell.exe -NoProfile start "$OPEN_URL"
  else
    echo -e "Unable to detect command to open browser.\n" >&2
    return 1
  fi
}

#######################################
main "$@"
