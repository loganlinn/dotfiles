function wezterm::set-user-vars() {
  hash base64 || return $?

	local format
	if [[ -z "${TMUX-}" ]]; then
		format='\033]1337;SetUserVar=%q=%s\007'
	else
		format='\033Ptmux;\033\033]1337;SetUserVar=%q=%s\007\033\\'
	fi

	for name_value; do
		local name="${name_value%%=*}"
		local value="${name_value#*=}"
    echo >&2 "wezterm::set-user-vars $name=$value"
		if [[ -n $name ]]; then
			local data
			if data="$(printf %s "$value" | base64)"; then
				printf "$format" "$name" "$data"
			fi
		else
			echo >&2 "invalid format: expected NAME=VALUE"
		fi
	done
}

function wezterm::export() {
	local usrvars=()
	for arg; do
		if [[ -z $arg ]]; then
			continue
		elif [[ $arg = *'='* ]]; then # name=value
			usrvars+=("$arg")
		else # name-only; use value from environment
			usrvars+=("$arg=${(P)arg}")
		fi
	done
	wezterm::set-user-vars "${usrvars[@]}"
}

function wezterm::init() {
  local -a user_vars
  for p in ${parameters[(I)WEZTERM_USER_VAR_*]}; do
    user_vars+=("${p#WEZTERM_USER_VAR_*}=${(P)p}")
  done
  wezterm::set-user-vars "${user_vars[@]}"
}
