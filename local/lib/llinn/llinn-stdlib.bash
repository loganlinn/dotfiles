#!/usr/bin/env bash
shopt -s gnu_errfmt
shopt -s nullglob
shopt -s extglob

# Config, change in the llinnrc
LLINN_LOG_FORMAT="${LLINN_LOG_FORMAT-llinn: %s}"

# Where llinn configuration should be stored
export LINN_CONFIG_DIR="${LLINN_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/llinn}"

__env_strictness() {
	local mode tmpfile old_shell_options
	local -i res

	tmpfile=$(mktemp)
	res=0
	mode="$1"
	shift

	set +o | grep 'pipefail\|nounset\|errexit' >"$tmpfile"
	old_shell_options=$(<"$tmpfile")
	rm -f tmpfile

	case "$mode" in
	strict)
		set -o errexit -o nounset -o pipefail
		;;
	unstrict)
		set +o errexit +o nounset +o pipefail
		;;
	*)
		log_error "Unknown strictness mode '${mode}'."
		exit 1
		;;
	esac

	if (($#)); then
		"${@}"
		res=$?
		eval "$old_shell_options"
	fi

	# Force failure if the inner script has failed and the mode is strict
	if [[ $mode = strict && $res -gt 0 ]]; then
		exit 1
	fi

	return $res
}

# Usage: strict_env [<command> ...]
#
# Turns on shell execution strictness. This will force the .envrc
# evaluation context to exit immediately if:
#
# - any command in a pipeline returns a non-zero exit status that is
#   not otherwise handled as part of `if`, `while`, or `until` tests,
#   return value negation (`!`), or part of a boolean (`&&` or `||`)
#   chain.
# - any variable that has not explicitly been set or declared (with
#   either `declare` or `local`) is referenced.
#
# If followed by a command-line, the strictness applies for the duration
# of the command.
#
# Example:
#
#    strict_env
#    has curl
#
#    strict_env has curl
strict_env() {
	__env_strictness strict "$@"
}

# Usage: unstrict_env [<command> ...]
#
# Turns off shell execution strictness. If followed by a command-line, the
# strictness applies for the duration of the command.
#
# Example:
#
#    unstrict_env
#    has curl
#
#    unstrict_env has curl
unstrict_env() {
	if (($#)); then
		__env_strictness unstrict "$@"
	else
		set +o errexit +o nounset +o pipefail
	fi
}

# Usage: log_status [<message> ...]
#
# Logs a status message. Acts like echo,
# but wraps output in the standard llinn log format
# (controlled by $LLINN_LOG_FORMAT), and directs it
# to stderr rather than stdout.
#
# Example:
#
#    log_status "Loading ..."
#
log_status() {
	if [[ -n $LLINN_LOG_FORMAT ]]; then
		local msg=$*
		# shellcheck disable=SC2059,SC1117
		printf "${LLINN_LOG_FORMAT}\n" "$msg" >&2
	fi
}

# Usage: log_error [<message> ...]
#
# Logs an error message. Acts like echo,
# but wraps output in the standard llinn log format
# (controlled by $LLINN_LOG_FORMAT), and directs it
# to stderr rather than stdout.
#
# Example:
#
#    log_error "Unable to find specified directory!"

log_error() {
	local color_normal
	local color_error
	color_normal=$(tput sgr0)
	color_error=$(tput setaf 1)
	if [[ -n $LLINN_LOG_FORMAT ]]; then
		local msg=$*
		# shellcheck disable=SC2059,SC1117
		printf "${color_error}${LLINN_LOG_FORMAT}${color_normal}\n" "$msg" >&2
	fi
}

# Usage: has <command>
#
# Returns 0 if the <command> is available. Returns 1 otherwise. It can be a
# binary in the PATH or a shell function.
#
# Example:
#
#    if has curl; then
#      echo "Yes we do"
#    fi
#
has() {
	type "$1" &>/dev/null
}

# Usage: join_args [args...]
#
# Joins all the passed arguments into a single string that can be evaluated by bash
#
# This is useful when one has to serialize an array of arguments back into a string
join_args() {
	printf '%q ' "$@"
}

# Usage: expand_path <rel_path> [<relative_to>]
#
# Outputs the absolute path of <rel_path> relative to <relative_to> or the
# current directory.
#
# Example:
#
#    cd /usr/local/games
#    expand_path ../foo
#    # output: /usr/local/foo
#
expand_path() {
	local REPLY
	realpath.absolute "${2+"$2"}" "${1+"$1"}"
	echo "$REPLY"
}

# --- vendored from https://github.com/bashup/realpaths
realpath.dirname() {
	REPLY=.
	! [[ $1 =~ /+[^/]+/*$|^//$ ]] || REPLY="${1%${BASH_REMATCH[0]}}"
	REPLY=${REPLY:-/}
}
realpath.basename() {
	REPLY=/
	! [[ $1 =~ /*([^/]+)/*$ ]] || REPLY="${BASH_REMATCH[1]}"
}

realpath.absolute() {
	REPLY=$PWD
	local eg=extglob
	! shopt -q $eg || eg=
	${eg:+shopt -s $eg}
	while (($#)); do case $1 in
		// | //[^/]*)
			REPLY=//
			set -- "${1:2}" "${@:2}"
			;;
		/*)
			REPLY=/
			set -- "${1##+(/)}" "${@:2}"
			;;
		*/*) set -- "${1%%/*}" "${1##${1%%/*}+(/)}" "${@:2}" ;;
		'' | .) shift ;;
		..)
			realpath.dirname "$REPLY"
			shift
			;;
		*)
			REPLY="${REPLY%/}/$1"
			shift
			;;
		esac; done
	${eg:+shopt -u $eg}
}

# Usage: user_rel_path <abs_path>
#
# Transforms an absolute path <abs_path> into a user-relative path if
# possible.
#
# Example:
#
#    echo $HOME
#    # output: /home/user
#    user_rel_path /home/user/my/project
#    # output: ~/my/project
#    user_rel_path /usr/local/lib
#    # output: /usr/local/lib
#
user_rel_path() {
	local abs_path=${1#-}

	if [[ -z $abs_path ]]; then return; fi

	if [[ -n $HOME ]]; then
		local rel_path=${abs_path#$HOME}
		if [[ $rel_path != "$abs_path" ]]; then
			abs_path=~$rel_path
		fi
	fi

	echo "$abs_path"
}

# Usage: find_up <filename>
#
# Outputs the path of <filename> when searched from the current directory up to
# /. Returns 1 if the file has not been found.
#
# Example:
#
#    cd /usr/local/my
#    mkdir -p project/foo
#    touch bar
#    cd project/foo
#    find_up bar
#    # output: /usr/local/my/bar
#
find_up() {
	(
		while true; do
			if [[ -f $1 ]]; then
				echo "$PWD/$1"
				return 0
			fi
			if [[ $PWD == / ]] || [[ $PWD == // ]]; then
				return 1
			fi
			cd ..
		done
	)
}

# Usage: PATH_add <path> [<path> ...]
#
# Prepends the expanded <path> to the PATH environment variable, in order.
# It prevents a common mistake where PATH is replaced by only the new <path>,
# or where a trailing colon is left in PATH, resulting in the current directory
# being considered in the PATH.  Supports adding multiple directories at once.
#
# Example:
#
#    pwd
#    # output: /my/project
#    PATH_add bin
#    echo $PATH
#    # output: /my/project/bin:/usr/bin:/bin
#    PATH_add bam boum
#    echo $PATH
#    # output: /my/project/bam:/my/project/boum:/my/project/bin:/usr/bin:/bin
#
PATH_add() {
	path_add PATH "$@"
}

# Usage: path_add <varname> <path> [<path> ...]
#
# Works like PATH_add except that it's for an arbitrary <varname>.
path_add() {
	local path i var_name="$1"
	# split existing paths into an array
	declare -a path_array
	IFS=: read -ra path_array <<<"${!1-}"
	shift

	# prepend the passed paths in the right order
	for ((i = $#; i > 0; i--)); do
		path_array=("$(expand_path "${!i}")" ${path_array[@]+"${path_array[@]}"})
	done

	# join back all the paths
	path=$(
		IFS=:
		echo "${path_array[*]}"
	)

	# and finally export back the result to the original variable
	export "$var_name=$path"
}

# Usage: MANPATH_add <path>
#
# Prepends a path to the MANPATH environment variable while making sure that
# `man` can still lookup the system manual pages.
#
# If MANPATH is not empty, man will only look in MANPATH.
# So if we set MANPATH=$path, man will only look in $path.
# Instead, prepend to `man -w` (which outputs man's default paths).
#
MANPATH_add() {
	local old_paths="${MANPATH:-$(man -w)}"
	local dir
	dir=$(expand_path "$1")
	export "MANPATH=$dir:$old_paths"
}

# Usage: PATH_rm <pattern> [<pattern> ...]
# Removes directories that match any of the given shell patterns from
# the PATH environment variable. Order of the remaining directories is
# preserved in the resulting PATH.
#
# Bash pattern syntax:
#   https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html
#
# Example:
#
#   echo $PATH
#   # output: /dontremove/me:/remove/me:/usr/local/bin/:...
#   PATH_rm '/remove/*'
#   echo $PATH
#   # output: /dontremove/me:/usr/local/bin/:...
#
PATH_rm() {
	path_rm PATH "$@"
}

# Usage: path_rm <varname> <pattern> [<pattern> ...]
#
# Works like PATH_rm except that it's for an arbitrary <varname>.
path_rm() {
	local path i discard var_name="$1"
	# split existing paths into an array
	declare -a path_array
	IFS=: read -ra path_array <<<"${!1}"
	shift

	patterns=("$@")
	results=()

	# iterate over path entries, discard entries that match any of the patterns
	# shellcheck disable=SC2068
	for path in ${path_array[@]+"${path_array[@]}"}; do
		discard=false
		# shellcheck disable=SC2068
		for pattern in ${patterns[@]+"${patterns[@]}"}; do
			if [[ "$path" == +($pattern) ]]; then
				discard=true
				break
			fi
		done
		if ! $discard; then
			results+=("$path")
		fi
	done

	# join the result paths
	result=$(
		IFS=:
		echo "${results[*]}"
	)

	# and finally export back the result to the original variable
	export "$var_name=$result"
}

# Usage: load_prefix <prefix_path>
#
# Expands some common path variables for the given <prefix_path> prefix. This is
# useful if you installed something in the <prefix_path> using
# $(./configure --prefix=<prefix_path> && make install) and want to use it in
# the project.
#
# Variables set:
#
#    CPATH
#    LD_LIBRARY_PATH
#    LIBRARY_PATH
#    MANPATH
#    PATH
#    PKG_CONFIG_PATH
#
# Example:
#
#    ./configure --prefix=$HOME/rubies/ruby-1.9.3
#    make && make install
#    # Then in the .envrc
#    load_prefix ~/rubies/ruby-1.9.3
#
load_prefix() {
	local REPLY
	realpath.absolute "$1"
	MANPATH_add "$REPLY/man"
	MANPATH_add "$REPLY/share/man"
	path_add CPATH "$REPLY/include"
	path_add LD_LIBRARY_PATH "$REPLY/lib"
	path_add LIBRARY_PATH "$REPLY/lib"
	path_add PATH "$REPLY/bin"
	path_add PKG_CONFIG_PATH "$REPLY/lib/pkgconfig"
}

# Usage: semver_search <directory> <folder_prefix> <partial_version>
#
# Search a directory for the highest version number in SemVer format (X.Y.Z).
#
# Examples:
#
# $ tree .
# .
# |-- dir
#     |-- program-1.4.0
#     |-- program-1.4.1
#     |-- program-1.5.0
# $ semver_search "dir" "program-" "1.4.0"
# 1.4.0
# $ semver_search "dir" "program-" "1.4"
# 1.4.1
# $ semver_search "dir" "program-" "1"
# 1.5.0
#
semver_search() {
	local version_dir=${1:-}
	local prefix=${2:-}
	local partial_version=${3:-}
	# Look for matching versions in $version_dir path
	# Strip possible "/" suffix from $version_dir, then use that to
	# strip $version_dir/$prefix prefix from line.
	# Sort by version: split by "." then reverse numeric sort for each piece of the version string
	# The first one is the highest
	find "$version_dir" -maxdepth 1 -mindepth 1 -type d -name "${prefix}${partial_version}*" |
		while IFS= read -r line; do echo "${line#${version_dir%/}/${prefix}}"; done |
		sort -t . -k 1,1rn -k 2,2rn -k 3,3rn |
		head -1
}

# Usage: on_git_branch [<branch_name>]
#
# Returns 0 if within a git repository with given `branch_name`. If no branch
# name is provided, then returns 0 when within _any_ branch. Requires the git
# command to be installed. Returns 1 otherwise.
#
# When a branch is specified, then `.git/HEAD` is watched so that
# entering/exiting a branch triggers a reload.
#
# Example (.envrc):
#
#    if on_git_branch child_changes; then
#      export MERGE_BASE_BRANCH=parent_changes
#    fi
#
#    if on_git_branch; then
#      echo "Thanks for contributing to a GitHub project!"
#    fi
on_git_branch() {
	local git_dir
	if ! has git; then
		log_error "on_git_branch needs git, which could not be found on your system"
		return 1
	elif ! git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null); then
		log_error "on_git_branch could not locate the .git directory corresponding to the current working directory"
		return 1
	elif [ -z "$1" ]; then
		return 0
	fi
	watch_file "$git_dir/HEAD"
	[ "$(git branch --show-current)" = "$1" ]
}
