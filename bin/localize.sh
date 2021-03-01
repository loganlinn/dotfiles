#!/usr/bin/env bash

set -e
[[ ${TRACE} ]] && set -x
set -ou pipefail

PROG_NAME=localize.sh
PROG_VERSION=0.1.0
PROG_TOOL_DEPS="curl jq mktemp"
PROG_CONFIG_HOME=${LOCALIZE_CONFIG_HOME:-${XDG_CONFIG_HOME:-${HOME}/.config}/${PROG_NAME}}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Check if all necessary tools are available.
for tool in ${PROG_TOOL_DEPS}; do
	if ! hash "$tool" >/dev/null; then
		echo >&2 "ERROR: cannot find \"$tool\"; check your PATH."
		echo >&2 "       You may need to run the following command or similar:"
		echo >&2 "         export PATH=\"/bin:/usr/bin:\$PATH\""
		exit 1
	fi
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

E_RED='\033[0;31m'
E_GREEN='\033[0;32m'
E_YELLOW='\033[1;33m'
E_WHITE='\033[1;37m'
E_BLUE='\033[1;34m'
E_PURPLE='\033[0;35m'
E_GREY='\033[1;30m'
E_NC='\033[0m'

L_FATAL=50
L_ERROR=40
L_WARNING=30
L_INFO=20
L_DEBUG=10
L_NOTSET=0

LOG_LEVEL="${LOG_LEVEL:-${DEBUG:+debug}}"
LOG_LEVEL="${LOG_LEVEL:-info}"

# @arg $1 string|number A name or ordinal for a log level
# @stdout An ordinal value for specified log level
l_level() {
	local level=${1,,}

	case "${level}" in
	fatal) : "${L_FATAL}" ;;
	error) : "${L_ERROR}" ;;
	warn*) : "${L_WARNING}" ;;
	info) : "${L_INFO}" ;;
	debug) : "${L_DEBUG}" ;;
	[0-9]+) : "${level}" ;;
	*) : "${L_NOTSET}" ;;
	esac

	printf %i "${_}"
}

# @bref Indicates if a message of severity level would be processed
# @exitcode 0 If specified level is enabled
# @exitcode 1 If specified level is not enabled
l_enabled() {
	count_args 1 "$@" || return 1

	local -i value threshold

	value=$(l_level "$1")
	threshold=$(l_level "${LOG_LEVEL}")

	if ((value < threshold)); then
		return 1
	fi
	return 0
}

# @stdout formatted log message when level is enabled
l_stdout() {
	local lvl=$1
	local msg=$2
	local esc=${3:-}

	l_enabled "${lvl}" || return 0

	read -r LINE SUB < <(caller 2 | cut -d ' ' -f 1,2)
	if l_enabled debug; then
		echo -ne "${E_GREY}[${SUB} ${LINE}]${E_NC} "
	fi
	echo -e "${esc}${lvl}${E_NC}: ${msg}${E_NC}"
}

# @stderr formatted log message when level is enabled
l_stderr() { l_stdout "${@}" 1>&2; }
l_debug() { l_stderr debug "${*}" "${E_PURPLE}"; }
l_info() { l_stderr info "${*}" "${E_BLUE}"; }
l_warn() { l_stderr warn "${*}" "${E_YELLOW}"; }
l_error() { l_stderr error "${*}" "${E_RED}"; }
l_fatal() {
	l_stderr fatal "${*}" "${E_RED}"
	exit 3
}

debug_args() {
	l_enabled debug || return 0

	local f=
	local a=
	local o='('

	f="$(caller 0 | cut -d ' ' -f 2)"

	for a in "${@}"; do
		o+="${a}, "
	done

	if [[ -z $* ]]; then
		l_debug "${E_WHITE}${f}${E_PURPLE} => (no args)"
	else
		l_debug "${E_WHITE}${f}${E_PURPLE} => ${o::-2})"
	fi
}

count_args() {
	local fname
	fname="$(caller 0 | cut -d ' ' -f 2)"

	if [[ $# -lt 1 ]]; then
		usage_error "${E_WHITE}${f}${E_RED} => count_args takes an expected count and an arglist."
	fi

	local expected=${1}
	local actual=$(($# - 1))
	local -a args
	args=("${@}")
	args=("${args[@]:2}")

	if [[ ${actual} -lt ${expected} ]]; then
		debug_args "${args[@]}"
		usage_error "${E_WHITE}${fname}${E_RED} expected at least ${expected} non-empty params. Got ${actual}"
	fi

	local -i i=0
	local arg

	for arg in "${args[@]}"; do
		if [[ ${i} -eq ${expected} ]]; then
			return 0
		fi

		if [[ -z ${arg} ]]; then
			debug_args "${args[@]}"
			usage_error "${E_WHITE}${fname}${E_RED} expected arg ${i} to be not-null."
		fi

		i=$((i + 1))
	done

	return 0
}

# @stderr Formatted usage message
l_usage() {
	count_args 1 "${@}" || return 1
	echo -e "${E_YELLOW}usage:${E_NC} ${*}" 1>&2
}

# @stderr error message and optional usage
# @exitcode 2 Reserved code for usage errors
usage_error() {
	local error=$1
	local usage=${2:-}

	l_error "${error}"
	if [[ -n ${usage+x} ]]; then
		l_usage "${usage}"
	fi
	exit 2
}

create_directory() {
  local directory=$1

	if ! [[ -d ${directory} ]]; then
		mkdir -p "${directory}"
		l_info "${E_GREEN}created${E_NC} ${directory}"
	fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LOCALIZE_API_URL=https://${LOCALIZE_API_HOST:-api.localizejs.com}/v2.0
LOCALIZE_CURL_OPTS="-s -S -l -f ${LOCALIZE_CURL_OPTS:-}"

# @brief Performs authenticated HTTP transation with API
localize::api() {
	count_args 1 "${@}"

	local endpoint=${LOCALIZE_API_URL}/${1}

	l_debug "fetching ${endpoint}"

	# shellcheck disable=SC2086
	curl ${LOCALIZE_CURL_OPTS} \
		--header "Authorization: Bearer ${LOCALIZE_TOKEN?}" \
		--url "${endpoint}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# @brief Lists all supported languages
localize::languages() {
	localize::api languages
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

localize::project() {
  declare usage="$PROG_NAME project [view|list]"

	count_args 1 "${@}"

	local cmd=${1-}
	shift

	case "${cmd}" in
	view) localize::project::view "$@" ;;
	list) localize::project::list "$@" ;;
	'') usage_error "missing command for '$PROG_NAME project'" ;;
	*) usage_error "unknown command '${cmd}' for '$PROG_NAME project'" ;;
	esac
}

localize::project::list() {
	localize::api projects | jq '.data'
}

localize::project::view() {
	localize::api "projects/${LOCALIZE_PROJECT_KEY?}" | jq '.data'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# TODO
# localize::content::import() { ... }
# localize::content::export() { ... }
localize::export() {
  declare usage="$PROG_NAME export [-t|--type phrase|glossary] [-f|--format <format>] <language>"

	debug_args "${@}"

	local content_type=phrase
	local format=${LOCALIZE_EXPORT_FORMAT:-SIMPLE_JSON}
  local language=

	while test $# -gt 0; do
		case "$1" in
		-h|--help)
      l_usage "${usage}"
      return
      ;;
    -t|--type)
      content_type=${2?type option requires value};
      shift
      ;;
    -f|--format)
      format=${2?format option requires value};
      shift
      ;;
    *)
      if [[ -n $language ]]; then
        l_error "invlaid option: ${1}"
        l_usage "${usage}"
      fi
      language=$1
    esac
    shift
  done

	if [[ -z $language ]]; then
		usage_error "missing argument: language" "${usage}"
	fi

	localize::api "projects/${LOCALIZE_PROJECT_KEY?}/resources?type=${content_type}&language=${language}&format=${format}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# localize::locale() {
#   local pattern="${LOCALE_EXPORT_PATH_PATTERN:-./locales/%locale%}"
#   printf 'locales'
# }

localize::pull() {
  local usage="$PROG_NAME pull [<language>... | --all]"

	# TODO make configurable
	local directory=locales

	local all_flag=
	local -a languages=()
	while test $# -gt 0; do
		case "$1" in
		-h|--help) l_usage "${usage}"; return 0;;
		--all) all_flag=1 ;;
    --debug) LOG_LEVEL=debug ;;
		*) languages+=("$1") ;;
		esac
		shift
	done

	if [[ $all_flag ]]; then
		if [[ ${#languages[@]} -gt 0 ]]; then
			usage_error "cannot combine --all with other languages" "${usage}"
		fi

		readarray -t languages < <(localize::project::view | jq -cr '.project.languages | sort | .[]')
		l_debug "all languages: ${languages[*]}"
	fi

	if [[ ${#languages[@]} -eq 0 ]]; then
		usage_error "missing language argument" "${usage}"
	fi

	for language in ${languages[*]}; do
    localize::export --format SIMPLE_JSON --type phrase "${language}" \
      | postprocess_namespace_split - "${directory}/${language}"
	done
}

# parse "<namespace>:<phrase-key>" from keys
postprocess_namespace_split() {
  count_args 2 "${@}"

  local input_path=${1?}
  local output_dir=${2?}

  create_directory "${output_dir}"

	# and output one file per namespace.
	while IFS=$'\t' read -r namespace ns_content; do
		local ns_file="${output_dir}/${namespace//\"}.json"
    if [[ -f $ns_file ]]; then
      l_info "${E_GREEN}update${E_NC} ${ns_file}"
    else
      l_info "${E_GREEN}create${E_NC} ${ns_file}"
    fi
    l_debug "${ns_content}"

    jq -rS <<< "${ns_content}" >"$ns_file"
	done < <(jq -rc \
		'to_entries
     | map((.key | split(":")) as [$namespace, $key] | . + {$namespace, $key})
     | group_by(.namespace)[]
     | .[0].namespace + "\t" + (from_entries | tojson)
     ' "${input_path}"
   )
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

localize::main() {
	local config
	local profile

	while (($#)); do
		case "${1}" in

		-h | --help)
			shift
			_usage
			exit 0
			;;

		--debug)
			shift
			LOG_LEVEL=debug
			;;

		-V | --version)
			shift
			echo "${PROG_NAME}/${PROG_VERSION}"
			exit 0
			;;

		-q | --quiet)
			shift
			LOG_LEVEL=error
			;;

		-C)
			config="${2-}"
			shift
			shift
			[[ -n "${config}" ]] || usage_error 'missing config operand'
			[[ -f "${config}" ]] || usage_error "'${config}' is not a file"
			# TODO cleanup
			l_debug "loading config file: ${config}"
			# shellcheck source=/dev/null
			source "${config}"
			;;

		--profile)
			profile="${2-}"
			shift
			shift
			[[ -n "${profile}" ]] || usage_error 'missing profile operand'
			config="${PROG_CONFIG_HOME}/${profile}.profile"
			[[ -f "${config}" ]] || usage_error "config profile '${profile}' could not be found"
			l_debug "loading config profile: ${config}"
			# shellcheck source=/dev/null
			source "${config}"
			;;

		-*)
			l_error "unknown option '${1}'"
			_usage
			exit 1
			;;

		*) break ;;

		esac
	done

	l_debug "LOCALIZE_PROJECT_KEY=${LOCALIZE_PROJECT_KEY-}"

	local cmd
	cmd=${1:-}
	shift

	if [[ -z ${cmd} ]]; then
		l_error "missing required argument: command"
		_usage
		exit 1
	fi

	if ! declare -f "localize::${cmd}" >/dev/null; then
		l_error "unknown command: ${cmd}"
		_usage
		exit 1
	fi

	"localize::${cmd}" "${@}"
}

_usage() {
	echo -e "$(
		cat <<-EOM

			${E_WHITE}USAGE${E_NC}
			  $PROG_NAME [--version] [--help] [--debug] [--quiet]
			              [--profile <name>]
			              <command> [<args>]

			${E_WHITE}COMMANDS${E_NC}
			  api:       Make an authenticated Localize API request
			  project:   Manage and view projects
			  pull:      Downloads latest translations

			${E_WHITE}ENVIRONMENT VARIABLES${E_NC}
			  LOCALIZE_PROJECT_KEY
			  LOCALIZE_TOKEN
			  LOCALIZE_API_HOST
			  LOCALIZE_CURL_OPTS
			  LOCALIZE_CONFIG_HOME
			  LOG_LEVEL
			  DEBUG
			  TRACE

		EOM
	)"
}

localize::main "${@}"
