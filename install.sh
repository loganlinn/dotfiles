#!/usr/bin/env bash

set -e
set -u
set -o pipefail
[[ -z ${TRACE-} ]] || set -x

SCRIPT_NAME=${BASH_SOURCE[0]:-$0}
SCRIPT_DIR=$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1
	pwd -P
)

usage() {
	cat 1>&2 <<EOF
$SCRIPT_NAME - Installer for dotfiles toolchain

USAGE:
    $SCRIPT_NAME [FLAGS]

FLAGS:
    -v, --verbose           Enable verbose output
    -q, --quiet             Disable progress output
    -h, --help              Prints help information
EOF
}

main() {
	need_cmd uname
	need_cmd mktemp
	need_cmd chmod
	need_cmd mkdir
	need_cmd rm
	need_cmd rmdir

	downloader --check
	detect_architecture || return 1
	local _arch="$RETVAL"

	local _arg _sub_arg
	for _arg in "$@"; do
		case "$_arg" in
		--help)
			usage
			exit 0
			;;
		*)
			OPTIND=1
			if [ "${_arg%%--*}" = "" ]; then
				# Long option (other than --help);
				# don't attempt to interpret it.
				continue
			fi
			while getopts :h _sub_arg "$_arg"; do
				case "$_sub_arg" in
				h)
					usage
					exit 0
					;;
				*) ;;
				esac
			done
			;;
		esac
	done

	# chsh -s "$(which zsh)"
	say TODO

	say done.
}

say() {
	printf '%s: %s\n' "$SCRIPT_NAME" "$@"
}

err() {
	say "$@" >&2
	exit 1
}

need_cmd() {
	if ! check_cmd "$1"; then
		err "need '$1' (command not found)"
	fi
}

ensure() {
	if ! "$@"; then err "command failed: $*"; fi
}

# This wraps curl or wget. Try curl first, if not installed,
# use wget instead.
downloader() {
	local _dld
	local _ciphersuites
	local _err
	local _status
	if check_cmd curl; then
		_dld=curl
	elif check_cmd wget; then
		_dld=wget
	else
		_dld='curl or wget' # to be used in error message of need_cmd
	fi

	if [ "$1" = --check ]; then
		need_cmd "$_dld"
	elif [ "$_dld" = curl ]; then
		get_ciphersuites_for_curl
		_ciphersuites="$RETVAL"
		if [ -n "$_ciphersuites" ]; then
			_err=$(curl --proto '=https' --tlsv1.2 --ciphers "$_ciphersuites" --silent --show-error --fail --location "$1" --output "$2" 2>&1)
			_status=$?
		else
			echo "Warning: Not enforcing strong cipher suites for TLS, this is potentially less secure"
			if ! check_help_for "$3" curl --proto --tlsv1.2; then
				echo "Warning: Not enforcing TLS v1.2, this is potentially less secure"
				_err=$(curl --silent --show-error --fail --location "$1" --output "$2" 2>&1)
				_status=$?
			else
				_err=$(curl --proto '=https' --tlsv1.2 --silent --show-error --fail --location "$1" --output "$2" 2>&1)
				_status=$?
			fi
		fi
		if [ -n "$_err" ]; then
			echo "$_err" >&2
			if echo "$_err" | grep -q 404$; then
				err "installer for platform '$3' not found, this may be unsupported"
			fi
		fi
		return $_status
	elif [ "$_dld" = wget ]; then
		get_ciphersuites_for_wget
		_ciphersuites="$RETVAL"
		if [ -n "$_ciphersuites" ]; then
			_err=$(wget --https-only --secure-protocol=TLSv1_2 --ciphers "$_ciphersuites" "$1" -O "$2" 2>&1)
			_status=$?
		else
			echo "Warning: Not enforcing strong cipher suites for TLS, this is potentially less secure"
			if ! check_help_for "$3" wget --https-only --secure-protocol; then
				echo "Warning: Not enforcing TLS v1.2, this is potentially less secure"
				_err=$(wget "$1" -O "$2" 2>&1)
				_status=$?
			else
				_err=$(wget --https-only --secure-protocol=TLSv1_2 "$1" -O "$2" 2>&1)
				_status=$?
			fi
		fi
		if [ -n "$_err" ]; then
			echo "$_err" >&2
			if echo "$_err" | grep -q ' 404 Not Found$'; then
				err "installer for platform '$3' not found, this may be unsupported"
			fi
		fi
		return $_status
	else
		err "Unknown downloader" # should not reach here
	fi
}

detect_architecture() {
	local _ostype _cputype _bitness _arch _clibtype
	_ostype="$(uname -s)"
	_cputype="$(uname -m)"
	_clibtype="gnu"

	if [ "$_ostype" = Linux ]; then
		if [ "$(uname -o)" = Android ]; then
			_ostype=Android
		fi
		if ldd --version 2>&1 | grep -q 'musl'; then
			_clibtype="musl"
		fi
	fi

	if [ "$_ostype" = Darwin ] && [ "$_cputype" = i386 ]; then
		# Darwin `uname -m` lies
		if sysctl hw.optional.x86_64 | grep -q ': 1'; then
			_cputype=x86_64
		fi
	fi

	if [ "$_ostype" = SunOS ]; then
		# Both Solaris and illumos presently announce as "SunOS" in "uname -s"
		# so use "uname -o" to disambiguate.  We use the full path to the
		# system uname in case the user has coreutils uname first in PATH,
		# which has historically sometimes printed the wrong value here.
		if [ "$(/usr/bin/uname -o)" = illumos ]; then
			_ostype=illumos
		fi

		# illumos systems have multi-arch userlands, and "uname -m" reports the
		# machine hardware name; e.g., "i86pc" on both 32- and 64-bit x86
		# systems.  Check for the native (widest) instruction set on the
		# running kernel:
		if [ "$_cputype" = i86pc ]; then
			_cputype="$(isainfo -n)"
		fi
	fi

	case "$_ostype" in

	Android)
		_ostype=linux-android
		;;

	Linux)
		check_proc
		_ostype=unknown-linux-$_clibtype
		_bitness=$(get_bitness)
		;;

	FreeBSD)
		_ostype=unknown-freebsd
		;;

	NetBSD)
		_ostype=unknown-netbsd
		;;

	DragonFly)
		_ostype=unknown-dragonfly
		;;

	Darwin)
		_ostype=apple-darwin
		;;

	illumos)
		_ostype=unknown-illumos
		;;

	MINGW* | MSYS* | CYGWIN*)
		_ostype=pc-windows-gnu
		;;

	*)
		err "unrecognized OS type: $_ostype"
		;;

	esac

	case "$_cputype" in

	i386 | i486 | i686 | i786 | x86)
		_cputype=i686
		;;

	xscale | arm)
		_cputype=arm
		if [ "$_ostype" = "linux-android" ]; then
			_ostype=linux-androideabi
		fi
		;;

	armv6l)
		_cputype=arm
		if [ "$_ostype" = "linux-android" ]; then
			_ostype=linux-androideabi
		else
			_ostype="${_ostype}eabihf"
		fi
		;;

	armv7l | armv8l)
		_cputype=armv7
		if [ "$_ostype" = "linux-android" ]; then
			_ostype=linux-androideabi
		else
			_ostype="${_ostype}eabihf"
		fi
		;;

	aarch64 | arm64)
		_cputype=aarch64
		;;

	x86_64 | x86-64 | x64 | amd64)
		_cputype=x86_64
		;;

	mips)
		_cputype=$(get_endianness mips '' el)
		;;

	mips64)
		if [ "$_bitness" -eq 64 ]; then
			# only n64 ABI is supported for now
			_ostype="${_ostype}abi64"
			_cputype=$(get_endianness mips64 '' el)
		fi
		;;

	ppc)
		_cputype=powerpc
		;;

	ppc64)
		_cputype=powerpc64
		;;

	ppc64le)
		_cputype=powerpc64le
		;;

	s390x)
		_cputype=s390x
		;;
	riscv64)
		_cputype=riscv64gc
		;;
	*)
		err "unknown CPU type: $_cputype"
		;;

	esac

	# Detect 64-bit linux with 32-bit userland
	if [ "${_ostype}" = unknown-linux-gnu ] && [ "${_bitness}" -eq 32 ]; then
		case $_cputype in
		x86_64)
			if [ -n "${RUSTUP_CPUTYPE:-}" ]; then
				_cputype="$RUSTUP_CPUTYPE"
			else {
				# 32-bit executable for amd64 = x32
				if is_host_amd64_elf; then {
					echo "This host is running an x32 userland; as it stands, x32 support is poor," 1>&2
					echo "and there isn't a native toolchain -- you will have to install" 1>&2
					echo "multiarch compatibility with i686 and/or amd64, then select one" 1>&2
					echo "by re-running this script with the RUSTUP_CPUTYPE environment variable" 1>&2
					echo "set to i686 or x86_64, respectively." 1>&2
					echo 1>&2
					echo "You will be able to add an x32 target after installation by running" 1>&2
					echo "  rustup target add x86_64-unknown-linux-gnux32" 1>&2
					exit 1
				}; else
					_cputype=i686
				fi
			}; fi
			;;
		mips64)
			_cputype=$(get_endianness mips '' el)
			;;
		powerpc64)
			_cputype=powerpc
			;;
		aarch64)
			_cputype=armv7
			if [ "$_ostype" = "linux-android" ]; then
				_ostype=linux-androideabi
			else
				_ostype="${_ostype}eabihf"
			fi
			;;
		riscv64gc)
			err "riscv64 with 32-bit userland unsupported"
			;;
		esac
	fi

	# Detect armv7 but without the CPU features Rust needs in that build,
	# and fall back to arm.
	# See https://github.com/rust-lang/rustup.rs/issues/587.
	if [ "$_ostype" = "unknown-linux-gnueabihf" ] && [ "$_cputype" = armv7 ]; then
		if ensure grep '^Features' /proc/cpuinfo | grep -q -v neon; then
			# At least one processor does not have NEON.
			_cputype=arm
		fi
	fi

	_arch="${_cputype}-${_ostype}"

	RETVAL="$_arch"
}
