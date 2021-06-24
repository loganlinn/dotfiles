#!/usr/bin/env zsh

asdf-upgrade() {
  local tool=$1
  local vnext=$2
  local vprev vfile

  [[ -n $tool ]] || tool=$(asdf list 2>/dev/null | grep -v '^[ ]' | fzf) || return $?
  [[ -n $vnext ]] || vnext=$(asdf latest "$tool") || return $?
  read -r vprev vsource < <(asdf current "$tool" 2>/dev/null | awk '{ print $2, $3 }')

  echo "-> asdf install $tool $vnext"
  asdf install "$tool" "$vnext" || return $?

	if [[ $vsrc == ~/"${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-.tool-versions}" ]]; then
		read -q "?asdf global $tool $vnext? (y/n) " && asdf global "$tool" "$vnext"
  elif [[ $vsrc == *"environment variable" ]]; then
		read -q "?asdf shell $tool $vnext? (y/n) " && asdf shell "$tool" "$vnext"
  else
		read -q "?asdf local $tool $vnext? (y/n) " && asdf local "$tool" "$vnext"
  fi

  [[ -z $vprev ]] ||
    read -q "?asdf uninstall $tool $vprev? (y/n) " &&
    asdf uninstall "$tool" "$vprev"
}
